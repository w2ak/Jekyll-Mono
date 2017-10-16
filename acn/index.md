---
layout: post
title: ACN Master
toc: true
author: Clément Durand
date: 2017-09-11
permalink: /acn/

---

*Notes regarding the ACN master.*

---

# Description

* WordPress: [acn2017@wp.imt.fr](https://acn2017.wp.imt.fr/)

# Courses

## ACN902 Core IP

ACN902/INF678B: *Core IP Network*

### Pages

* SynapseS: [acn902@synapses.telecom-paristech.fr](https://synapses.telecom-paristech.fr/catalogue/2017-2018/ue/10739/ACN902-core-ip-network-inf678b)
* Teaching: [acn902@sitepedago.telecom-paristech.fr](https://sitepedago.telecom-paristech.fr/front/site_CoreIPNet.html)

### Lectures

*The slides are distributed under the « Cadre privé » license which doesn't allow me to put them here online.*

### Practicals

* 2017-09-22 BGP Practical
  * [Initial config]({% link acn/bgp-practical/config.md %})
  * [Clément]({% link acn/bgp-practical/clement.md %})
  * [Carolina]({% link acn/bgp-practical/carolina.md %})
* 2017-10-13 MPLS Practical
  * [Carolina]({% link acn/mpls-practical/carolina-clement.md %})

## ACN906 Cellular

ACN906: *Cellular Access for High Data Rates*

### Pages

* SynapseS: [acn906@synapses.telecom-paristech.fr](https://synapses.telecom-paristech.fr/catalogue/2017-2018/ue/10631/ACN906-cellular-access-for-high-data-rates)
* [Frédéric Launay's blog](http://blogs.univ-poitiers.fr/f-launay/) is, sadly, written in french.
* [LTE course](http://www.3glteinfo.com/lte-tutorial-free-online-lte-training-courses/). Yet untested.

### Lectures

* An introduction to cellular systems: from 2G to 4G
  * 2017-09-11 [Lecture 01](/share/acn/906/01-lte-archi-acn.pdf)
  * 2017-09-18 Lecture 02 (slides of Lecture 01)
  * [4G Diagram by Carol](/share/acn/906/lte-schema.pdf)
* 4G Air Interface
  * 2017-09-25 [Lecture 03](/share/acn/906/03-lte-phy-mac-rlc.pdf)
  * 2017-10-02 Lecture 03 (slides of Lecture 02)
  * [TD notes]({% link acn/lte-air-interface.md %})

## ACN910 Protocols

ACN910/INF672: *Protocol Verification and Safety*

### Pages

* Teacher: [acn910@prosecco.gforge.inria.fr](http://prosecco.gforge.inria.fr/personal/karthik/teaching/ACN910.html)
* SynapseS: [acn901@synapses.telecom-paristech.fr](https://synapses.telecom-paristech.fr/catalogue/2017-2018/ue/10825/ACN901-protocol-safety-and-verification)

### Lectures
* Introduction, Motivating examples
  * 2017-09-15 [Lecture 01](/share/acn/910/lecture01.pdf)
    * [Engineering with Logic: HOL Specification and Symbolic-Evaluation Testing for TCP Implementations.](http://www.cl.cam.ac.uk/~pes20/Netsem/paper3.pdf)
    In POPL 2006.<br/>
    Steve Bishop, Matthew Fairbairn, Michael Norrish, Peter Sewell, Michael Smith, Keith Wansbrough.
    * [Rigorous specification and conformance testing techniques for network protocols, as applied to TCP, UDP, and Sockets.](http://www.cl.cam.ac.uk/~pes20/Netsem/paper.pdf)
    In SIGCOMM 2005.<br/>
    Steve Bishop, Matthew Fairbairn, Michael Norrish, Peter Sewell, Michael Smith, Keith Wansbrough.
    * [The stable paths problem and interdomain routing.](/share/acn/910/00993304.pdf)
    In IEEE TON'02.<br/>
    TG Griffin, F Bruce Shepherd, G Wilfong.
    * [Toward a lightweight model of BGP safety.](/share/acn/910/bgp-wripe11.pdf)
    In WRiPE'11.<br/>
    M Arye, R Harrison, R Wang, P Zave, J Rexford
* Network protocol verification: Spin
  * [Install Spin](spin/)<br/>
  *It is advised to install it and not use the Virtual Machine provided.*
  * 2017-09-22 [Lecture 02](/share/acn/910/lecture02.pdf)
    * [Spin doc&examples](/share/acn/910/spin.zip)
  * 2017-09-29 [Lecture 03](/share/acn/910/lecture03.pdf)
    * [Exercises](/share/acn/910/exercises.zip)
  * 2017-10-06 [Lecture 04](/share/acn/910/lecture04.pdf)
    * [TCP Full model](/share/acn/910/tcp-full.pml)
    * [TLS state machine](/share/acn/910/tls.pml)
* Program Verification: Properties, Tools and Techniques
  * 2017-10-13 [Lecture 05](/404){:class="broken"}
  * 2017-10-20 [Lecture 06](/404){:class="broken"}
  * 2017-10-27 [Lecture 07](/404){:class="broken"}
  * 2017-10-03 [Lecture 08](/404){:class="broken"}
* Security protocol verification: ProVerif
  * 2017-10-10 [Lecture 09](/404){:class="broken"}
* Exam
  * 2017-10-17 [Exam](/404){:class="broken"}

## ACN913 Graphs

ACN 913: *Propagation in Graphs*

### Pages

* Install Jupyter for Python3 with [Anaconda](https://www.anaconda.com/download/)
* [Github](https://github.com/balouf/INF674) contains every material for the practicals
* SynapseS: [acn903@synapses.telecom-paristech.fr](https://synapses.telecom-paristech.fr/catalogue/2017-2018/ue/10417/ACN903-propagation-in-graphs)

### Practicals

* 2017-09-29 Galton Watson processes
  * [Clément](/share/acn/913/tp/01-Galton-Watson-TP.html)
  * [Correction](/404){:class="broken")
* 2017-10-13 Erdös-Rényi graphs
  * [Clément](/share/acn/913/tp/02-Erdos-Renyi-TP.html){:class="broken"}
  * [Correction](/404){:class="broken")
* 2017-10-16 Epidemic Competition
  * [Clément](/share/acn/913/tp/03-Competitive-Epidemics-TP.html){:class="broken"}
  * [Correction](/404){:class="broken")

## Resources

Every resource from the master can be found in [acn@share.neze.fr](/share/acn/).
