---
layout: post
title: Router configurations
author: Clément Durand
category:
 - computer-science
 - fav
toc: true
---

On Wednesday January 25th in class we started a network lab. The aim is to configure a whole network with our personal machines, choosing the address zones and setting up routing and firewall.

# Map of the network

![The network map]({{site.url}}/images/network-schema.jpg)

## Internet access

```bash
{% include_relative routers/internet.sh %}
```

## Head router

```bash
{% include_relative routers/head.sh %}
```

### Internal router 1

```bash
{% include_relative routers/internal-1.sh %}
```

### Internal router 2

This one is the router I have been configuring. Here's the configuration script in its current state.

```bash
{% include_relative routers/internal-2.sh %}
```

## ISP Head

```bash
{% include_relative routers/isp-head.sh %}
```

### Box 1

```bash
{% include_relative routers/box-1.sh %}
```

### Box 2

```bash
{% include_relative routers/box-2.sh %}
```

# Notes

## Addresses configuration

*Attribute an IP address to an interface.*

```bash
ip link set eth0 down
ip addr flush dev eth0
ip addr add dev eth0 192.168.1.42/24
ip link set eth0 up
```

```bash
ip addr list dev eth0
```

```bash
sysctl -w net.ipv4.ip_forward=1 # or 0
```

## Routes configuration

*Show routes*

```bash
ip route show
route -n
```

*Add routes*

```bash
ip route add 192.168.1.0/24 dev eth0      # one hop
ip route add 10.1.0.0/16 via 192.168.1.69 # gateway
ip route add default via 192.168.1.1      # default
```

```bash
ip route flush dev eth0
```
