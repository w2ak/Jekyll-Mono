---
layout: post
title: Firewall configuration
category: computer-science
author: Clément Durand
---

*Wrapping your mind arount iptables.*

---

# Basic firewall configuration

## Accepting or dropping everything

```bash
{% include_relative firewall/accept.iptable %}
```

```bash
iptables -t filter -P INPUT DROP
iptables -t filter -P FORWARD DROP
```

```bash
{% include_relative firewall/drop.iptable %}
```

## Accepting established connections

```bash
iptables -I INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -I FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
```

## Accepting specific inputs

Accepting traffic on loopback:

```bash
iptables -I INPUT -i lo -j ACCEPT
```

Accepting ping traffic:

```bash
iptables -A INPUT -p icmp -m limit --limit 2/sec -j ACCEPT
```

Accepting DNS requests

```bash
iptables -A INPUT -d $DNS_IP -p udp -m udp --dport 53 -j ACCEPT
```

## Accepting messages getting out of your subnet

```bash
iptables -A FORWARD -i $LAN_iface -o $WAN_iface -s $LAN_subnet -j ACCEPT
iptables -A FORWARD -i $LAN_iface -o $WAN_iface -j DROP
```

## Logging drops

```bash
iptables -A INPUT -m limit --limit 30/min -j LOG --log-prefix "iptables INPUT denied: " --log-level 7
```
