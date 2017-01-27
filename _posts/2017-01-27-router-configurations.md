---
layout: post
title: Router configurations
author: Clément Durand
---

On Wednesday January 25th in class we started a network lab. The aim is to configure a whole network with our personal machines, choosing the address zones and setting up routing and firewall.

## Map of the network

![The network map]({{site.url}}/images/network-schema.jpg)

## Internal router 2

This one is the router I have been configuring. Here's the configuration script in its current state.

```bash
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

## LAN CONFIG
# GET THE LAN IFACE INFOS
LAN=$(getlinks | sed -n '1 p')
LAN_MAC=$(getmac $LAN)
# CONFIGURE THE LAN ADDRESSES INFOS
LAN_IP=10.1.2.1
LAN_SN=$LAN_IP/24 # subnet

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

# CONFIGURE ADDRESSES AND ROUTES
msg "Setting up lan zone."      &&
    ip addr add $LAN_SN dev $LAN
msg "Setting up wan zone."      &&
    ip addr add $WAN_SN dev $WAN
msg "Setting up default route." &&
    ip route add default via $GW_IP

# ENABLE ROUTING
msg "Enabling routing."         &&
    sysctl net.ipv4.conf.all.forwarding=1 >/dev/null
msg "Opening firewall."         &&
    fw ACCEPT

# SET UP WEB ACCESS
msg "Setting up dns servers."   &&
cat > /etc/resolv.conf << EOF
nameserver 129.104.201.53
nameserver 129.104.201.51
EOF

# SET UP USER CONFIG
uconfname=$(mktemp)
cat > $uconfname << EOF
export http_proxy='http://129.104.247.2:8080/'
export https_proxy=\$http_proxy
export vizier=10.1.2.2
export durand=10.1.3.2
export girol=10.1.3.1
EOF
msg "If you want to use the user configuration, just do \`source $uconfname\`."
```
