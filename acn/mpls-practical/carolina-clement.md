---
layout: post
title: MPLS Practical
toc: true
author: Carolina De Senne Garcia, Clément Durand
date: 2017-10-13
permalink: /acn/mpls-practical/carolina.html
back: /acn/

---

# TP MPLS

### Question 1

To know which labels PE1 is going to use for each destination node, we can check its mpls bindings table, as follows:

```
PE1# show mpls ip bindings
  10.0.0.1/32
        in label:     16
        out label:    imp-null  lsr: 10.0.0.1:0       inuse
        out label:    16        lsr: 10.0.0.2:0
  10.0.0.2/32
        in label:     25
        out label:    imp-null  lsr: 10.0.0.2:0       inuse
        out label:    22        lsr: 10.0.0.1:0
  10.0.0.11/32
        in label:     imp-null
        out label:    17        lsr: 10.0.0.1:0
        out label:    17        lsr: 10.0.0.2:0
  10.0.0.12/32
        in label:     24
        out label:    21        lsr: 10.0.0.1:0       inuse
        out label:    24        lsr: 10.0.0.2:0       inuse
  10.0.0.13/32
        in label:     23
        out label:    18        lsr: 10.0.0.2:0       inuse
        out label:    20        lsr: 10.0.0.1:0       inuse
  10.0.0.14/32
        in label:     17
        out label:    16        lsr: 10.0.0.1:0       inuse
        out label:    19        lsr: 10.0.0.2:0       inuse
```

From this table, we deduce the next hops and respective labels for each destination:

 * PE1 -> P1: no label via P1
 * PE1 -> P2: no label via P2
 * PE1 -> PE2: label 21 via P1 OR(load-balanced) label 24 via P2
 * PE1 -> PE3: label 18 via P2 OR(lb) label 20 via P1
 * PE1 -> RR: label 16 via P1 OR(lb) label 19 via P2

We do the same for PE3:

```
PE3# sh mp ip b
  10.0.0.1/32
        in label:     16
        out label:    16        lsr: 10.0.0.2:0
        out label:    imp-null  lsr: 10.0.0.1:0       inuse
  10.0.0.2/32
        in label:     17
        out label:    imp-null  lsr: 10.0.0.2:0       inuse
        out label:    22        lsr: 10.0.0.1:0
  10.0.0.11/32
        in label:     18
        out label:    17        lsr: 10.0.0.2:0       inuse
        out label:    17        lsr: 10.0.0.1:0       inuse
  10.0.0.12/32
        in label:     27
        out label:    21        lsr: 10.0.0.1:0       inuse
        out label:    24        lsr: 10.0.0.2:0       inuse
  10.0.0.13/32
        in label:     imp-null
        out label:    18        lsr: 10.0.0.2:0
        out label:    20        lsr: 10.0.0.1:0
  10.0.0.14/32
        in label:     19
        out label:    19        lsr: 10.0.0.2:0       inuse
        out label:    16        lsr: 10.0.0.1:0       inuse
```

 * PE3 -> P2: no label via P1
 * PE3 -> P2: no label via P2
 * PE3 -> PE1: label 17 via P1 OR P2 (lb)
 * PE3 -> PE2: label 21 via P1 OR(lb) label 24 via P2
 * PE3 -> RR: label 19 via P2 OR(lb) label 16 via P1

### Question 2

We start by checking the PE1's forwarding MPLS table towards PE3 (10.0.0.13) to find the next hops and labels corresponding to those hops.
We find label 20 through P1 (interface 10.0.111.1) and label 18 though P2 (interface 10.0.112.2). Then, for each next hop, P1 (10.0.0.1) and P2 (10.0.0.2),
we verify that they forward packets to PE3 through their respective interfaces (10.0.113.12 and 10.0.132.13) by poping out the previous label.

```
PE1# sh mp fo 10.0.0.13
Local      Outgoing   Prefix           Bytes Label   Outgoing   Next Hop
Label      Label      or Tunnel Id     Switched      interface
23         20         10.0.0.13/32     0             Gi0/0      10.0.111.1
           18         10.0.0.13/32     0             Gi0/1      10.0.112.2

P1# sh mp fo 10.0.0.13
Local      Outgoing   Prefix           Bytes Label   Outgoing   Next Hop
Label      Label      or Tunnel Id     Switched      interface
20         Pop Label  10.0.0.13/32     747           Gi0/3      10.0.131.13

P2# sh mp fo 10.0.0.13
Local      Outgoing   Prefix           Bytes Label   Outgoing   Next Hop
Label      Label      or Tunnel Id     Switched      interface
18         Pop Label  10.0.0.13/32     9932          Gi0/3      10.0.132.13
```

`PE1(10.0.0.11) ------ 20 -----> P1(10.0.0.1) ------ xx -----> PE3(10.0.0.13)`
`PE1(10.0.0.11) ------ 18 -----> P2(10.0.0.2) ------ xx -----> PE3(10.0.0.13)`

The same approach was used to find out the routes and lables for the path PE3 --> PE1:
```
PE3# sh mp fo 10.0.0.11
Local      Outgoing   Prefix           Bytes Label   Outgoing   Next Hop
Label      Label      or Tunnel Id     Switched      interface
18         17         10.0.0.11/32     0             Gi0/0      10.0.131.1
           17         10.0.0.11/32     0             Gi0/1      10.0.132.2

P1# sh mp fo 10.0.0.11
Local      Outgoing   Prefix           Bytes Label   Outgoing   Next Hop
Label      Label      or Tunnel Id     Switched      interface
17         Pop Label  10.0.0.11/32     428           Gi0/0      10.0.111.11

P2# sh mp fo 10.0.0.11
Local      Outgoing   Prefix           Bytes Label   Outgoing   Next Hop
Label      Label      or Tunnel Id     Switched      interface
17         Pop Label  10.0.0.11/32     10465         Gi0/1      10.0.112.11
```

`PE3(10.0.0.13) ------ 17 -----> P1(10.0.0.1) ------ xx -----> PE1(10.0.0.11)`
`PE3(10.0.0.13) ------ 17 -----> P2(10.0.0.2) ------ xx -----> PE1(10.0.0.11)`

### Question 3

When disconnecting and reconnecting PE1 to P1, P1 will send again every `label in` it has
to PE1. For example, it sends label 22 corresponding to `10.0.0.2` and label 3 corresponding
to `10.0.0.1`.

Label 3 is a reserved label (every label up to 15 is reserved) for "implicitly null".

### Question 4

Prefixes corresponding to *connected* subnets (i.e. neighbors, loopback) that are not
reached thanks to the iBGP (OSPF here) are associated to label 3. Indeed, because of
penultimate hop popping (PHP), P1 (for example) advertises "no label" for every connected
destination. The other destinations (discovered thanks to OSPF) get a label that is also
advertised.

### Question 5

VPN Blue already configured between CA1 and CA2:

{% foldhl text linenos %}
CA1
conf t
 router bgp 65100
  network 100.100.1.0 mask 255.255.255.0
  neighbor 10.100.111.1 remote-as 10
  exit
 exit
PE1
conf t
 ip vrf BLUE
  rd 10:100
  route-target export 10:100
  route-target import 10:100
  exit
 interface GigabitEthernet0/2
  ip vrf forwarding BLUE
  exit
 router bgp 10
  address-family ipv4 vrf BLUE
   neighbor 10.100.111.1 remote-as 65100
   neighbor 10.100.111.1 activate
   neighbor 10.100.111.1 as-override
   exit-address-family
  exit
 exit
CA2
conf t
 router bgp 65100
  network 100.100.2.0 mask 255.255.255.0
  neighbor 10.100.132.13 remote-as 10
  exit
 exit
PE3
conf t
 ip vrf BLUE
  rd 10:100
  route-target export 10:100
  route-target import 10:100
  exit
 interface GigabitEthernet0/2
  ip vrf forwarding BLUE
  exit
 router bgp 10
  address-family ipv4 vrf BLUE
   neighbor 10.100.132.2 remote-as 65100
   neighbor 10.100.132.2 activate
   neighbor 10.100.132.2 as-override
   exit-address-family
  exit
 exit
{% endfoldhl %}

VPN Green:

```
CB1
conf t
 interface Loopback0
  ip address 200.200.1.1 255.255.255.0
  exit
 interface GigabitEthernet0/0
  no shutdown
  ip address 10.200.112.1 255.255.255.0
  exit
 router bgp 65200
  network 200.200.1.0 mask 255.255.255.0
  neighbor 10.200.112.12 remote-as 10
  exit
 exit
PE2
conf t
 ip vrf GREEN
  rd 10:200
  route-target export 10:200
  route-target import 10:200
  exit
 interface GigabitEthernet0/2
  ip vrf forwarding GREEN
  ip address 10.200.112.12 255.255.255.0
  no shutdown
  exit
 router bgp 10
  address-family ipv4 vrf GREEN
   neighbor 10.200.112.1 remote-as 65200
   neighbor 10.200.112.1 activate
   neighbor 10.200.112.1 as-override
   exit-address-family
  exit
 exit
CB2
conf t
 interface Loopback0
  ip address 200.200.2.2 255.255.255.0
  exit
 interface GigabitEthernet0/0
  no shutdown
  ip address 10.200.132.2 255.255.255.0
  exit
 router bgp 65200
  network 200.200.2.0 mask 255.255.255.0
  neighbor 10.200.132.13 remote-as 10
PE3
conf t
 ip vrf GREEN
  rd 10:200
  route-target export 10:200
  route-target import 10:200
  exit
 interface GigabitEthernet0/3
  ip vrf forwarding GREEN
  ip address 10.200.132.13 255.255.255.0
  no shutdown
  exit
 router bgp 10
  address-family ipv4 vrf GREEN
   neighbor 10.200.132.2 remote-as 65200
   neighbor 10.200.132.2 activate
   neighbor 10.200.132.2 as-override
   exit-address-family
  exit
 exit
```

### Question 6

#### Detailed: CA1 to CA2

```
CA1# sh ip route 100.100.2.2
  * 10.100.111.11
  MPLS label: none
PE1# sh ip route vrf BLUE 100.100.2.2
  * 10.0.0.13
  MPLS label: 28
PE3# sh ip route vrf BLUE 100.100.2.2
  * 10.100.132.2
  MPLS label: none
```

From this we deduce `CA1 ----> PE1 -28-> PE3 ----> CA2`

```
PE1# sh mpls forwarding-table 10.0.0.13
  23 20   10.0.111.1
  23 18   10.0.111.2
P1# sh mp fo 10.0.0.13
  20 --   10.0.131.13
P2# sh mp fo 10.0.0.13
  18 --   10.0.132.13
```

This allows to complete the route:
```
                ,-18--> P2 ----.
            PE1 --20--> P1 -----`> PE3
CA1 ------> PE1 --------28-------> PE3 ------> CA2
```

#### Other routes

 * CA2 to CA1:
```
                ,-17--> P2 ----.
            PE3 --17--> P1 -----`> PE1
CA2 ------> PE3 --------28-------> PE1 ------> CA2
```

 * CB1 to CB2:
```
                ,-28--> P2 ----.
            PE2 --20--> P1 -----`> PE3
CB1 ------> PE2 --------29-------> PE3 ------> CA2
```

 * CB2 to CB1:
```
                ,-24--> P2 ----.
            PE3 --21--> P1 -----`> PE1
CB2 ------> PE3 --------28-------> PE1 ------> CA2
```

### Question 7

On the BGP level, everything is seen as if `AS65100` is in this network:

```
AS65100 ---- AS10 ---- AS10
```

In other words, `CA1` sees the network of `CA2` as being advertised by `AS10`.

### Question 8


