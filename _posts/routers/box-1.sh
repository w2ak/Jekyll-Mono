#!/bin/sh
INET_IFACE=eth0
INET_IP="10.2.1.3"
INTERNAL_IFACE=eth1
INTERNAL_IP="10.2.3.1"
# Structure of this script
# 1. Fresh start
#       1.1.    disable network manager
#       1.2.    disable routing
#       1.3.    delete routes
#       1.4.    delete ip addresses
# 2. Setting routes
#       2.1.    setup ip addresses
#       2.2.    setup route to local link
#       2.3.    setup route through gateways
# 3. Setup firewall
# 4. Enable routing
#======================================================================
#       Fresh Start
#======================================================================
#       1.1.    disable network manager
sudo service network-manager stop
#       1.2.    disable routing
sysctl -w net.ipv4.ip_forward=0
#       1.3.    delete routes
ip route flush
#       1.4.    delete ip addresses
echo "Please delete previous IP Addresses"
#======================================================================
#       Setting Routes
#======================================================================
#       2.1.    setup ip addresses
#       2.2.    setup route to local link
ip addr add $INET_IP/24 dev $INET_IFACE
ip addr add $INTERNAL_IP/24 dev $INTERNAL_IFACE
#       2.3.    setup route through gateways
ip route add 0.0.0.0/0 via 10.2.1.1 dev $INET_IFACE
#======================================================================
#       Setup Firewall
#======================================================================
#======================================================================
#       Enable Routing
#======================================================================
sysctl -w net.ipv4.ip_forward=1
