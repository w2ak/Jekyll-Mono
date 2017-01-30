---
layout: post
title: Router configurations
author: Clément Durand
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
