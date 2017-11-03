---
layout: page
title: Projects
permalink: /projects/
---

# Towards the world's fastest file server

VPP is a really fast software network stack that can
reach 1 Tbit per second for packet forwarding. Is it
possible to get close to these numbers for TCP content
delivery?

This project was focused on a specific bottleneck in
TCP static content delivery: **memory copies**. In a
transmission from the application to the clients there
are two memory copies. By reducing this number to zero
in most cases, the aim would be to make content delivery
faster and more scalable regarding the number of
simultaneous connections.

<details>
  <summary>Paper abstract</summary>

  <p>Content Delivery Networks (CDN) represent more than half of the Internet
  traffic since 2016. In CDN, static file delivery is slowed down by several
  bottlenecks among which are the memory copies. Considering that memory copies
  are one of the key limits in this domain, this paper presents a file server
  model intended to break down the number of memory copies during the handling
  of a client to zero.</p>

  <p>To make this possible, changes in implementations of the
  Transmission Control Protocol (TCP) are necessary. This paper proposes a
  segment-oriented TCP interface design that was integrated in the Vector Packet
  Processor project from {FD.io}, based on the hypothesis that the performance
  of this fast virtual router project can be beneficial to TCP.</p>

  <p>Such changes require the use of a dedicated byte-indexed segment queue which
  design is proposed in this paper. Tests on this data structure, including
  behaviour comparison with another candidate structure, show the usefulness
  of such a specific design. This paper also uses other tests of the proposed
  data structure to discuss a key element of its design regarding cache
  optimization.</p>

  <a href="http://share.neze.fr/towards-the-worlds-fastest-file-server.pdf">Read more...</a>
</details>
