#!/bin/sh
set -xe
LAN=enp0s25
WAN=enp0s29u1u1
systemctl stop network-manager.sh || true
sysctl net.ipv4.conf.all.forwarding=0
sysctl net.ipv6.conf.all.disable_ipv6=1
iptables-restore << EOF
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT DROP [0:0]
COMMIT
*raw
:PREROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
COMMIT
*nat
:PREROUTING DROP [0:0]
:POSTROUTING DROP [0:0]
COMMIT
EOF
for iface in $LAN $WAN; do
    ip link set $iface down
    ip link set $iface up
    ip addr flush dev $iface
    ip route flush dev $iface
done;
ip addr add 10.1.3.1/24 dev $LAN
ip addr add 10.3.1.1/16 dev $WAN
ip route add 10.1.2.0/24 via 10.1.3.2
ip route add 10.1.1.0/24 via 10.1.3.3
ip route add default via 10.3.3.1
iptables-restore << EOF
*filter
:INPUT DROP [0:0]
:FORWARD DROP [0:0]
:OUTPUT DROP [0:0]
:die - [0:0]
-A die -m limit --limit 1/second -j LOG
-A die -j REJECT --reject-with icmp-admin-prohibited
-A INPUT -i lo -j ACCEPT
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A INPUT -m state --state INVALID -j die
-A INPUT -p icmp -j ACCEPT
-A INPUT -j die
-A FORWARD -i $LAN -j ACCEPT
-A FORWARD -d 10.1.1.0/24 -j ACCEPT
-A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
-A FORWARD -j die
-A OUTPUT -j ACCEPT
COMMIT
*nat
:PREROUTING ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
COMMIT
EOF
sysctl net.ipv4.conf.all.forwarding=1
echo "nameserver 129.104.201.53" > /etc/resolv.conf
