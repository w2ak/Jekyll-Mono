---
layout: post
title: Traffic shaping tricks
category:
 - computer-science
 - notes
author: Clément Durand
---

*This is how I limited my dad's bandwidth on my server :°*

---

Assume you want to limit the bandwidth on your vpn for only specific clients by ip.

```sh
#!/bin/bash
NETCARD=tun0
MAXBANDWIDTH=8192 # kiB/s, i.e. 8MiB/s

# reinit
tc qdisc del dev $NETCARD root handle 1
tc qdisc add dev $NETCARD root handle 1: htb default 9999

# create default class
tc class add dev $NETCARD parent 1:0 classid 1:9999 htb rate $(( $MAXBANDWIDTH ))kbps ceil $(( $MAXBANDWIDTH ))kbps burst 5k prio 9999

# control bandwidth per IP
declare -A ipctrl
ipctrl[10.42.0.4]="128" # kB/s

mark=0
for ip in "${!ipctrl[@]}"
do
    mark=$(( mark + 1 ))
    bandwidth=${ipctrl[$ip]}

    # traffic shaping rule
    tc class add dev $NETCARD parent 1:0 classid 1:$mark htb rate $(( $bandwidth ))kbps ceil $(( $bandwidth ))kbps burst 5k prio $mark

    # netfilter packet marking rule
    #iptables -t mangle -A INPUT -i $NETCARD -s $ip -j CONNMARK --set-mark $mark
    iptables -I FORWARD -i $NETCARD -s $ip -j CONNMARK --set-mark $mark

    # filter that bind the two
    tc filter add dev $NETCARD parent 1:0 protocol ip prio $mark handle $mark fw flowid 1:$mark

    echo "IP $ip is attached to mark $mark and limited to $bandwidth kbps"
done

# propagate netfilter marks on connections
iptables -t mangle -A POSTROUTING -j CONNMARK --restore-mark
```
