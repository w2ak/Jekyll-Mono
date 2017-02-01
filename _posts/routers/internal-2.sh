#!/bin/sh
msg () {
  printf "%s%s%s\n" "$(tput setaf 2)" "$@" "$(tput sgr0)"
}

getlinks () {
  ip link | grep "^[0-9]" | sed 's/^[^:]*:\s*//; s/:.*$//' | grep "^eth"
}

getmac () {
  ip link show $1 | grep "link/ether" | awk '{ print $2 }'
}

fw () {
iptables-restore << EOF
*nat
:PREROUTING $1 [0:0]
:INPUT $1 [0:0]
:OUTPUT $1 [0:0]
:POSTROUTING $1 [0:0]
COMMIT
*filter
:INPUT $1 [0:0]
:FORWARD $1 [0:0]
:OUTPUT $1 [0:0]
COMMIT
EOF
}

dnsstatus () {
  service bind9 status | grep "Loaded" | sed 's/^[^:]*:\s*//' | awk '{ print $1 }'
}

## LAN CONFIG
# GET THE LAN IFACE INFOS
LAN=$(getlinks | sed -n '1 p')
LAN_MAC=$(getmac $LAN)
# CONFIGURE THE LAN ADDRESSES INFOS
LAN_IP=10.1.2.1
LAN_SN=$LAN_IP/24 # subnet
DNS_IP=10.1.2.53

## WAN CONFIG
# GET THE WAN IFACE INFOS
WAN=$(getlinks | sed -n '2 p')
[ -n "$WAN" ] || exit 1 # if no wan iface, exit
WAN_MAC=$(getmac $WAN)
# CONFIGURE THE WAN ADDRESSES INFOS
WAN_IP=10.1.3.2
WAN_SN=$WAN_IP/24
# CONFIGURE THE GATEWAY INFOS (who do I talk to to get to the internet?)
GW_IP=10.1.3.1
LAN1_IP=10.1.3.3
LAN1_SN=10.1.1.0/24

## PROMPT FOR CHECKS
printf "%sLAN card: %s (%s)\tWAN card: %s (%s)\nOK? [y/n] %s" \
       "$(tput setaf 1)" "$LAN" "$LAN_MAC" "$WAN" "$WAN_MAC" "$(tput sgr0)"
read ans
[ "x$ans" = "xy" ] || exit 1

## START CONFIGURING THE NETWORK
# BRING EVERYTHING DOWN
msg "Stopping network manager." &&
    service network-manager stop
msg "Bringing links down."      &&
    for iface in $LAN $WAN; do echo $iface; ip link set dev $iface down; done
msg "Flushing ip addresses."    &&
    for iface in $LAN $WAN; do echo $iface; ip addr flush dev $iface; done
msg "Flushing routes."          &&
    for iface in $LAN $WAN; do echo $iface; ip route flush dev $iface; done
# BRING LINKS BACK UP
msg "Bringing links up."        &&
    for iface in $LAN $WAN; do echo $iface; ip link set dev $iface up; done
# DISABLE ROUTING
msg "Disabling routing."        &&
    sysctl net.ipv4.conf.all.forwarding=0 >/dev/null
msg "Blocking firewall."        &&
    fw DROP
#msg "Stopping dns server."      &&
    #service bind9 stop

# CONFIGURE ADDRESSES AND ROUTES
msg "Setting up lan zone."      &&
    ip addr add $LAN_SN dev $LAN
msg "Setting up dns address."   &&
    ip addr add $DNS_IP dev $LAN
msg "Setting up wan zone."      &&
    ip addr add $WAN_SN dev $WAN
msg "Setting up default route." &&
    ip route add default via $GW_IP
msg "Setting up lan2 route."    &&
    ip route add $LAN1_SN via $LAN1_IP

# ENABLE ROUTING
msg "Enabling routing."         &&
    sysctl net.ipv4.conf.all.forwarding=1 >/dev/null
msg "Setting up firewall"       &&
iptables-restore << EOF
*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]

#-A PREROUTING -m limit --limit 30/min -j LOG --log-prefix "iptables nat PREROUTING: " --log-level 7

#-A INPUT -m limit --limit 30/min -j LOG --log-prefix "iptables nat INPUT: " --log-level 7

#-A OUTPUT -m limit --limit 30/min -j LOG --log-prefix "iptables nat OUTPUT: " --log-level 7

#-A POSTROUTING -m limit --limit 30/min -j LOG --log-prefix "iptables nat POSTROUTING: " --log-level 7

COMMIT
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
:LOGINVALID - [0:0]

-A INPUT -i lo -j ACCEPT
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A INPUT -p icmp -m limit --limit 2/sec -j ACCEPT
-A INPUT -d $DNS_IP -p udp -m udp --dport 53 -j ACCEPT
-A INPUT -d $LAN_IP -p tcp -m tcp --dport 22 -j ACCEPT
-A INPUT -m state --state INVALID -j LOGINVALID
-A INPUT -m limit --limit 30/min -j LOG --log-prefix "iptables filter INPUT: " --log-level 7
-A INPUT -j REJECT --reject-with icmp-port-unreachable

-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -i $LAN -o $WAN -s $LAN_SN -j ACCEPT
-A FORWARD -i $WAN -o $LAN -d $LAN_SN -p tcp --dport 22 -j ACCEPT
-A FORWARD -m state --state INVALID -j LOGINVALID
-A FORWARD -m limit --limit 30/min -j LOG --log-prefix "iptables filter FORWARD: " --log-level 7
-A FORWARD -j REJECT --reject-with icmp-port-unreachable

-A OUTPUT -m state --state INVALID -j LOGINVALID
#-A OUTPUT -m limit --limit 30/min -j LOG --log-prefix "iptables filter OUTPUT: " --log-level 7

-A LOGINVALID -m limit --limit 30/min -j LOG --log-prefix "iptables filter INVALID: " --log-level 7
-A LOGINVALID -j DROP

COMMIT
EOF

# SET UP WEB ACCESS
msg "Setting up dns servers."   &&
cat > /etc/resolv.conf << EOF
search inf586 eleves.polytechnique.fr polytechnique.fr
nameserver 10.1.2.53
EOF

# SET UP DNS SERVER
msg "Setting up dns options."   &&
cat > /etc/bind/named.conf.options << EOF
options {
  directory "/var/cache/bind";
  recursion yes;
  forwarders {
    129.104.201.53;
    129.104.201.51;
    129.104.32.41;
    129.104.30.41;
  };
  dnssec-validation auto;
  auth-nxdomain no;
  listen-on-v6 { any; };
};
EOF
msg "Setting up dns zones."     &&
cat > /etc/bind/named.conf.default-zones << EOF
zone "." {
  type hint;
  file "/etc/bind/db.root";
};
zone "localhost" {
  type master;
  file "/etc/bind/db.local";
};
zone "inf586" {
  type master;
  file "/etc/bind/db.inf586";
};
zone "127.in-addr.arpa" {
  type master;
  file "/etc/bind/db.127";
};
zone "0.in-addr.arpa" {
  type master;
  file "/etc/bind/db.0";
};
zone "255.in-addr.arpa" {
  type master;
  file "/etc/bind/db.255";
};
zone "10.in-addr.arpa" {
  type master;
  file "/etc/bind/db.10";
};
EOF
msg "Setting up dns resolution." &&
cat > /etc/bind/db.inf586 << EOF
\$TTL 604800
@ IN  SOA inf586. root.inf586. (
      $(date +%m%d%H%M%S)   ; Serial
       604800   ; Refresh
        86400   ; Retry
      2419200   ; Expire
       604800 ) ; Negative Cache TTL
;
@ IN  NS  inf586.
@ IN  A 10.1.2.53

internet-in IN  A 10.3.3.1

head-router-out IN  A 10.3.1.1
www IN  CNAME head-router-out
head-router-in  IN  A 10.1.3.1
head-router-client IN A 10.1.3.86

internal-router-1-out IN A 10.1.3.3
internal-router-1-in IN A 10.1.1.1
internal-router-1-client IN A 10.1.1.86

internal-router-2-out IN A 10.1.3.2
internal-router-2-in IN A 10.1.2.1
internal-router-2-client IN A 10.1.2.86
vizier  IN  CNAME internal-router-2-client
nameserver IN A 10.1.2.53

isp-head-out  IN  A 10.3.2.1
isp-head-in IN  A 10.2.1.1

box-1-out IN  A 10.2.1.2
box-2-out IN  A 10.2.1.3
EOF
msg "Setting up dns reverse."    &&
cat > /etc/bind/db.10 << EOF
\$TTL 604800
@ IN  SOA inf586. root.inf586. (
      $(date +%m%d%H%M%S)   ; Serial
       604800   ; Refresh
        86400   ; Retry
      2419200   ; Expire
       604800 ) ; Negative Cache TTL
;
@ IN  NS  inf586.
1.3.3 IN  PTR internet-in

1.1.3 IN  PTR head-router-out
1.3.1 IN  PTR head-router-in

3.3.1 IN  PTR internal-router-1-out
1.1.1 IN  PTR internal-router-1-in
86.1.1  IN  PTR internal-router-1-client

2.3.1 IN  PTR internal-router-2-out
1.2.1 IN  PTR internal-router-2-in
86.2.1  IN  PTR internal-router-2-client
53.2.1  IN  PTR nameserver

1.2.3 IN  PTR isp-head-out
1.1.2 IN  PTR isp-head-in

2.1.2 IN  PTR box-1-out
3.1.2 IN  PTR box-2-out
EOF
msg "Starting dns server."      && service bind9 restart

# SET UP USER CONFIG
uconfname=$(mktemp)
cat > $uconfname << EOF
export http_proxy='http://129.104.247.2:8080/'
export https_proxy=\$http_proxy
export vizier=10.1.2.86
export durand=10.1.3.2
export girol=10.1.3.1
export gaspard=10.3.3.1
export burns=10.1.3.3

export kuzh=129.104.247.2
export frankiz=129.104.201.51
EOF
msg "If you want to use the user configuration, just do \`source $uconfname\`."
