---
layout: post
title: 4-month long internship @CiscoFR
category:
    - computer-science
    - school
    - wip
toc: true
author: Clément Durand
---

*Research internship spent at Cisco France for my third year at the École polytechnique, tutored by Mark Townsley and Pierre Pfister.*

---

# Initial goals

*Crafting the world's fastest file server* was originally the goal of the internship. Based on a few simple ideas a project was created to implement a tcp content delivery server that would be as fast as possible.

## Background ideas

### Stateless TCP

For a scientific project at the École polytechnique and with two friends, we actually worked on how far we could get trying to implement a stateless version of TCP designed for static content delivery, each content corresponding to its own IPv6 address.

We quickly reached the point where we couldn't do without any state and decided to keep the server stateless by keeping a small state in the lower bits of the server-side sequence number. By slightly tuning the size of each data we would send, it allowed us to control the lower bits of the acknowledgement number we would then receive from the client, letting us keep a little amount of state in the packets.

This project raised the question of how to make a TCP server really fast, which might have been possible with our idea while it wasn't completely TCP compliant. With this objective in mind we talked about caching in content delivery.

### Using cache in content delivery networks

In content delivery networks you will find a lot of caching. By using big slow servers far from the client, and putting smaller but faster servers close to them, providers created trees of caching servers which, provided the right algorithms to choose wich data to cache where, allow CDNs to get faster by doing load balancing and accessing popular data faster.

Anyway, in one of the fastest servers (corresponding to a leaf of the tree), when a content is required the data still has to be copied and packed into tcp packets that will be sent. The main idea we talked about was then to avoid copying the data too many times. There seems to be no use copying the data to a packet for every user requesting it while we might be able to reuse the packet, changing only the headers and updating the checksum, allowing us to only write headers for multiple clients and drastically limit the amount of memory copies we would need to do.

The idea was then to try and implement this idea inside the open source Vector Packet Processing project.

## The VPP project

> « The Vector Packet Processor (VPP) is a recently open-sourced technology enabling unprecedented packet forwarding performance. Part of the [FD.io](fd.io) project, and leveraging DPDK, it is the world fastest software based router, and is maintained by a growing open-source community including companies such as Intel, Cisco or Ericsson. »
> <br/>*-- Pierre Pfister*{:.signature}
