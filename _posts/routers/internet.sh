#!/bin/sh
# CONFIGURATION
inetif="wlan0"
locif="eth0"
echo "First, you have to connect to a wifi network allowing access to kuzh"
# SECURE EVERYTHING
sysctl net.ipv4.conf.all.forwarding=0
sysctl net.ipv6.conf.all.disable_ipv6=1
# SAVE IPTABLES FOR FUTURE RESTORATION
iptables-save > "saved-iptables.$(date -Iseconds)"
# BLOCK EVERYTHING
iptables-restore <<EOF
*raw
:PREROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
COMMIT
*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
COMMIT
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
COMMIT
EOF
# FLUSH LOCAL IFACE
ip link set $locif down
ip link set $locif up
ip addr flush dev $locif
ip route flush dev $locif
# ADD ADDRESS AND ROUTES
ip addr add 10.3.3.1/16 dev $locif
ip route add 10.1.0.0/16 via 10.3.1.1
ip route add 10.2.0.0/16 via 10.3.2.1
# SETUP NAT AND FIREWALL
iptables-restore <<EOF
*nat
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -o $inetif -s 10.0.0.0/8 -j MASQUERADE
COMMIT
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT ACCEPT [0:0]
-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A FORWARD -p tcp -i $locif --dport 8080 -d 129.104.247.2 -j ACCEPT
-A FORWARD -p udp -i $locif --dport 53 -d 129.104.0.0/16 -j ACCEPT
-A FORWARD -p tcp -i $locif --dport 993 -d 149.202.54.192 -j ACCEPT
-A FORWARD -j REJECT
-A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A INPUT -j REJECT
COMMIT
EOF
# ALLOW FORWARDING
sysctl net.ipv4.conf.all.forwarding=1
