---
layout: post
title: BGP Practical
toc: true
author: Clément Durand
date: 2017-10-05
permalink: /acn/bgp-practical/clement.html
back: /acn/

---

# Multi-homed network

## Question 1.1

*Configure the BGP router of AS10 to prohibit transit.*

For each AS2,6,9 (they are providers), add the community "local-AS" on incoming
routes such that they are not advertized for these routes will be deleted on
output.

{% foldhl text linenos %}
 enable
 configure terminal
 router bgp 10
  neighbor 100.0.0.2 route-map rm-prov2-in in
  neighbor 100.0.0.6 route-map rm-prov6-in in
  neighbor 100.0.0.9 route-map rm-prov9-in in
  exit
 route-map rm-prov2-in permit 10
  set community local-AS
  exit
 route-map rm-prov6-in permit 10
  set community local-AS
  exit
 route-map rm-prov9-in permit 10
  set community local-AS
  exit
 exit
{% endfoldhl %}

## Question 1.2

*Explain the changes needed in the BGP configuration so as to route **outgoing**
internet traffic from AS10 through either AS9 or AS6 but not through AS2. AS2
must only be used as a last resort.*

Add a local preference to each AS such that routes going through AS6 or AS9 are
prefered.

{% foldhl text linenos %}
 enable
 configure terminal
 route-map rm-prov2-in permit 10
  set local-preference 100
  exit
 route-map rm-prov6-in permit 10
  set local-preference 200
  exit
 route-map rm-prov9-in permit 10
  set local-preference 200
  exit
 exit
{% endfoldhl %}

## Question 1.3

*Explain the changes needed so as to route the **incoming** traffic through AS6
or AS9 and not through AS2.*

Path prepending can be used to shape incoming traffic.

{% foldhl text linenos %}
 enable
 configure terminal
 router bgp 10
  neighbor 100.0.0.2 route-map rm-prov2-out out
  exit
 route-map rm-prov2-out permit 10
  set as-path prepend 10 10 10
  exit
 exit
{% endfoldhl %}

## Question 1.4

*How can the shaping applied by AS10 for the incoming traffic be bypassed by other ASs?*

Peers can still bypass path prepending with their local preferences.

## Questions 1.1-4 reset

{% foldhl text linenos %}
 enable
 configure terminal
 router bgp 10
  no neighbor 100.0.0.2 route-map rm-prov2-in in
  no neighbor 100.0.0.2 route-map rm-prov2-out out
  no neighbor 100.0.0.6 route-map rm-prov6-in in
  no neighbor 100.0.0.9 route-map rm-prov9-in in
  exit
 no route-map rm-prov2-in permit 10
 no route-map rm-prov2-out permit 10
 no route-map rm-prov6-in permit 10
 no route-map rm-prov9-in permit 10
 exit
{% endfoldhl %}

# Carriers

## Question 2.1

Some AS do not see every possible route towards AS10 because, in the
advertisement process, every router only advertises its best path towards AS10.
For example, `1-5-8-9-10` will not be found in the table of AS1 because the best
path from AS5 to AS10 is actually `5-6-10`. *Every router can only have one path
per neighbor.*

Another important element is Poison Reverse. AS1 uses `1-5-6-10` as its best
path. It will not advertise it to AS5 __because the next hop in this path is
AS5__. AS5 only sees paths for next hops AS6 and AS8. *Every router can only
have __at most__ one path per neighbor.*

### Theoretical routes advertisement

{% foldhl text linenos %}
 Step 0.
  AS10 advertises [10]
               to {2,6,9}
 Step 1. {2,6,9} received an advertisement
  AS2  now has [2,10]
       advertises [2,10]
               to {1,3,10} - {10} = {1,3}
  AS6  now has [6,10]
       advertises [6,10]
               to {3,5,10} - {10} = {3,5}
  AS9  now has [9,10]
       advertises [9,10]
               to {7,8,10} - {10} = {7,8}
 Step 2. {1,3,5,7,8} received an advertisement
  AS1  now has [1,2,10]
       advertises [1,2,10]
               to {2,3,4,5} - {2,10} = {3,4,5}
  AS3  now has [3,2,10]
               [3,6,10]
       advertises [3,2,10]
               to {1,2,6} - {2,10} = {1,6}
  AS5  now has [5,6,10]
       advertises [5,6,10]
               to {1,6,8} - {6,10} = {1,8}
  AS7  now has [7,9,10]
       advertises [7,9,10]
               to {4,9} - {9,10} = {4}
  AS8  now has [8,9,10]
       advertises [8,9,10]
               to {5,9} - {9,10} = {5}
 Step 3. {1,3,4,5,6,8} received an advertisement
  AS1  now has [1,2,10]
               [1,3,2,10]
               [1,5,6,10]
       does not advertise [1,2,10]
  AS3  now has [3,2,10]
               [3,2,10]
               [3,1,2,10]
       does not advertise [3,2,10]
  AS4  now has [4,1,2,10]
               [4,7,9,10]
       advertises [4,1,2,10]
               to {1,7} - {1,2,10} = {7}
  AS5  now has [5,6,10]
               [5,1,2,10]
               [5,8,9,10]
       does not advertise [5,6,10]
  AS6  now has [6,10]
               [6,3,2,10]
       does not advertise [6,10]
  AS8  now has [8,9,10]
               [8,5,6,10]
       does not advertise [8,9,10]
 Step 4. {7} received an advertisement
  AS7  now has [7,9,10]
               [7,4,1,2,10]
       does not advertise [7,9,10]
{% endfoldhl %}

In the end, we expect the following paths towards 10.

{% foldhl text linenos %}
 +-----+--------+------+
 | src | path   | dst  |
 +-----+--------+------+
 |     |>       |      |
 | AS1 |    3 2 |      |
 |     |    5 6 |      |
 +-----+--------+      |
 | AS2 |>       |      |
 +-----+--------+      |
 |     |>     2 |      |
 | AS3 |      6 |      |
 |     |    1 2 |      |
 +-----+--------+      |
 | AS4 |>   1 2 |      |
 |     |    7 9 |      |
 +-----+--------+      |
 |     |>     6 | AS10 |
 | AS5 |    1 2 |      |
 |     |    8 9 |      |
 +-----+--------+      |
 | AS6 |>       |      |
 |     |    3 2 |      |
 +-----+--------+      |
 | AS7 |>     9 |      |
 |     |  4 1 2 |      |
 +-----+--------+      |
 | AS8 |>     9 |      |
 |     |    5 6 |      |
 +-----+--------+      |
 | AS9 |>       |      |
 +-----+--------+------+
{% endfoldhl %}

### Check

This is confirmed by running the following in each AS BGP router.

{% foldhl text linenos %}
 enable
 show ip bgp all
{% endfoldhl %}

## Question 2.2

### AS1

{% foldhl text linenos %}
 enable
 configure terminal
 router bgp 1
  network 1.0.0.0 route-map rm-internal
  neighbor 100.0.12.2 route-map rm-prov-in in
  neighbor 100.0.12.2 route-map rm-prov-out out
  neighbor 100.0.13.3 route-map rm-peer-in in
  neighbor 100.0.13.3 route-map rm-peer-out out
  neighbor 100.0.14.4 route-map rm-cust-in in
  neighbor 100.0.14.4 route-map rm-cust-out out
  neighbor 100.0.15.5 route-map rm-cust-in in
  neighbor 100.0.15.5 route-map rm-cust-out out
  exit
 route-map rm-internal permit 10
  set community 300
  exit
 route-map rm-prov-in permit 10
  set local-preference 100
  set community 100
  exit
 route-map rm-prov-out permit 10
  match community cl-clients
  exit
 route-map rm-peer-in permit 10
  set local-preference 200
  set community 200
  exit
 route-map rm-peer-out permit 10
  match community cl-clients
  exit
 route-map rm-cust-in permit 10
  set local-preference 300
  set community 300
  exit
 route-map rm-cust-out permit 10
  match community cl-everybody
  exit
 ip community-list standard cl-clients permit 300
 ip community-list standard cl-everybody permit 300
 ip community-list standard cl-everybody permit 200
 ip community-list standard cl-everybody permit 100
 exit
{% endfoldhl %}

This could be simplified into

{% foldhl text linenos %}
 enable
 configure terminal
 router bgp 1
  network 1.0.0.0 route-map rm-cust-in
  neighbor 100.0.12.2 route-map rm-prov-in in
  neighbor 100.0.12.2 route-map rm-prov-out out
  neighbor 100.0.13.3 route-map rm-peer-in in
  neighbor 100.0.13.3 route-map rm-peer-out out
  neighbor 100.0.14.4 route-map rm-cust-in in
  neighbor 100.0.15.5 route-map rm-cust-in in
  exit
 route-map rm-prov-in permit 10
  set local-preference 100
  exit
 route-map rm-peer-in permit 10
  set local-preference 200
  exit
 route-map rm-cust-in permit 10
  set local-preference 300
  set community 300
  exit
 route-map rm-prov-out permit 10
  match community cl-clients
  exit
 ip community-list standard cl-clients permit 300
 exit
{% endfoldhl %}

### AS2

{% foldhl text linenos %}
 enable
 configure terminal
 router bgp 2
  network 2.0.0.0 route-map rm-internal
  neighbor 100.0.0.10 route-map rm-cust-in in
  neighbor 100.0.0.10 route-map rm-cust-out out
  neighbor 100.0.12.1 route-map rm-cust-in in
  neighbor 100.0.12.1 route-map rm-cust-out out
  neighbor 100.0.23.3 route-map rm-cust-in in
  neighbor 100.0.23.3 route-map rm-cust-out out
  exit
 route-map rm-internal permit 10
  set community 300
  exit
 route-map rm-cust-in permit 10
  set local-preference 300
  set community 300
  exit
 route-map rm-cust-out permit 10
  match community cl-everybody
  exit
 ip community-list standard cl-everybody permit 300
 ip community-list standard cl-everybody permit 200
 ip community-list standard cl-everybody permit 100
 exit
{% endfoldhl %}

### AS3

{% foldhl text linenos %}
 enable
 configure terminal
 router bgp 3
  network 3.0.0.0 route-map rm-internal
  neighbor 100.0.13.1 route-map rm-peer-in in
  neighbor 100.0.13.1 route-map rm-peer-out out
  neighbor 100.0.23.2 route-map rm-prov-in in
  neighbor 100.0.23.2 route-map rm-prov-out out
  neighbor 100.0.36.6 route-map rm-cust-in in
  neighbor 100.0.36.6 route-map rm-cust-out out
  exit
 route-map rm-internal permit 10
  set community 300
  exit
 route-map rm-prov-in permit 10
  set local-preference 100
  set community 100
  exit
 route-map rm-prov-out permit 10
  match community cl-clients
  exit
 route-map rm-peer-in permit 10
  set local-preference 200
  set community 200
  exit
 route-map rm-peer-out permit 10
  match community cl-clients
  exit
 route-map rm-cust-in permit 10
  set local-preference 300
  set community 300
  exit
 route-map rm-cust-out permit 10
  match community cl-everybody
  exit
 ip community-list standard cl-clients permit 300
 ip community-list standard cl-everybody permit 300
 ip community-list standard cl-everybody permit 200
 ip community-list standard cl-everybody permit 100
 exit
{% endfoldhl %}

### AS4

{% foldhl text linenos %}
 enable
 configure terminal
 router bgp 4
  network 4.0.0.0 route-map rm-internal
  neighbor 100.0.14.1 route-map rm-prov-in in
  neighbor 100.0.14.1 route-map rm-prov-out out
  neighbor 100.0.47.7 route-map rm-cust-in in
  neighbor 100.0.47.7 route-map rm-cust-out out
  exit
 route-map rm-internal permit 10
  set community 300
  exit
 route-map rm-prov-in permit 10
  set local-preference 100
  set community 100
  exit
 route-map rm-prov-out permit 10
  match community cl-clients
  exit
 route-map rm-cust-in permit 10
  set local-preference 300
  set community 300
  exit
 route-map rm-cust-out permit 10
  match community cl-everybody
  exit
 ip community-list standard cl-clients permit 300
 ip community-list standard cl-everybody permit 300
 ip community-list standard cl-everybody permit 200
 ip community-list standard cl-everybody permit 100
 exit
{% endfoldhl %}

### AS5

{% foldhl text linenos %}
 enable
 configure terminal
 router bgp 5
  network 5.0.0.0 route-map rm-internal
  neighbor 100.0.15.1 route-map rm-prov-in in
  neighbor 100.0.15.1 route-map rm-prov-out out
  neighbor 100.0.56.6 route-map rm-peer-in in
  neighbor 100.0.56.6 route-map rm-peer-out out
  neighbor 100.0.58.8 route-map rm-cust-in in
  neighbor 100.0.58.8 route-map rm-cust-out out
  exit
 route-map rm-internal permit 10
  set community 300
  exit
 route-map rm-prov-in permit 10
  set local-preference 100
  set community 100
  exit
 route-map rm-prov-out permit 10
  match community cl-clients
  exit
 route-map rm-peer-in permit 10
  set local-preference 200
  set community 200
  exit
 route-map rm-peer-out permit 10
  match community cl-clients
  exit
 route-map rm-cust-in permit 10
  set local-preference 300
  set community 300
  exit
 route-map rm-cust-out permit 10
  match community cl-everybody
  exit
 ip community-list standard cl-clients permit 300
 ip community-list standard cl-everybody permit 300
 ip community-list standard cl-everybody permit 200
 ip community-list standard cl-everybody permit 100
 exit
{% endfoldhl %}

### AS6

{% foldhl text linenos %}
 enable
 configure terminal
 router bgp 6
  network 6.0.0.0 route-map rm-internal
  neighbor 100.0.0.10 route-map rm-cust-in in
  neighbor 100.0.0.10 route-map rm-cust-out out
  neighbor 100.0.36.3 route-map rm-prov-in in
  neighbor 100.0.36.3 route-map rm-prov-out out
  neighbor 100.0.56.5 route-map rm-peer-in in
  neighbor 100.0.56.5 route-map rm-peer-out out
  exit
 route-map rm-internal permit 10
  set community 300
  exit
 route-map rm-prov-in permit 10
  set local-preference 100
  set community 100
  exit
 route-map rm-prov-out permit 10
  match community cl-clients
  exit
 route-map rm-peer-in permit 10
  set local-preference 200
  set community 200
  exit
 route-map rm-peer-out permit 10
  match community cl-clients
  exit
 route-map rm-cust-in permit 10
  set local-preference 300
  set community 300
  exit
 route-map rm-cust-out permit 10
  match community cl-everybody
  exit
 ip community-list standard cl-clients permit 300
 ip community-list standard cl-everybody permit 300
 ip community-list standard cl-everybody permit 200
 ip community-list standard cl-everybody permit 100
 exit
{% endfoldhl %}

### AS7

{% foldhl text linenos %}
 enable
 configure terminal
 router bgp 7
  network 7.0.0.0 route-map rm-internal
  neighbor 100.0.47.4 route-map rm-prov-in in
  neighbor 100.0.47.4 route-map rm-prov-out out
  neighbor 100.0.79.9 route-map rm-cust-in in
  neighbor 100.0.79.9 route-map rm-cust-out out
  exit
 route-map rm-internal permit 10
  set community 300
  exit
 route-map rm-prov-in permit 10
  set local-preference 100
  set community 100
  exit
 route-map rm-prov-out permit 10
  match community cl-clients
  exit
 route-map rm-cust-in permit 10
  set local-preference 300
  set community 300
  exit
 route-map rm-cust-out permit 10
  match community cl-everybody
  exit
 ip community-list standard cl-clients permit 300
 ip community-list standard cl-everybody permit 300
 ip community-list standard cl-everybody permit 200
 ip community-list standard cl-everybody permit 100
 exit
{% endfoldhl %}

### AS8

{% foldhl text linenos %}
 enable
 configure terminal
 router bgp 8
  network 8.0.0.0 route-map rm-internal
  neighbor 100.0.58.5 route-map rm-prov-in in
  neighbor 100.0.58.5 route-map rm-prov-out out
  neighbor 100.0.89.9 route-map rm-cust-in in
  neighbor 100.0.89.9 route-map rm-cust-out out
  exit
 route-map rm-internal permit 10
  set community 300
  exit
 route-map rm-prov-in permit 10
  set local-preference 100
  set community 100
  exit
 route-map rm-prov-out permit 10
  match community cl-clients
  exit
 route-map rm-cust-in permit 10
  set local-preference 300
  set community 300
  exit
 route-map rm-cust-out permit 10
  match community cl-everybody
  exit
 ip community-list standard cl-clients permit 300
 ip community-list standard cl-everybody permit 300
 ip community-list standard cl-everybody permit 200
 ip community-list standard cl-everybody permit 100
 exit
{% endfoldhl %}

### AS9-1

{% foldhl text linenos %}
 enable
 configure terminal
 router bgp 9
  network 9.0.0.0 route-map rm-internal
  neighbor 100.0.0.10 route-map rm-cust-in in
  neighbor 100.0.0.10 route-map rm-cust-out out
  exit
 route-map rm-internal permit 10
  set community 300
  exit
 route-map rm-cust-in permit 10
  set local-preference 300
  set community 300
  exit
 route-map rm-cust-out permit 10
  match community cl-everybody
  exit
 ip community-list standard cl-everybody permit 300
 ip community-list standard cl-everybody permit 200
 ip community-list standard cl-everybody permit 100
 exit
{% endfoldhl %}

### AS9-2

{% foldhl text linenos %}
 enable
 configure terminal
 router bgp 9
  network 9.0.0.0 route-map rm-internal
  neighbor 100.0.89.8 route-map rm-prov-in in
  neighbor 100.0.89.8 route-map rm-prov-out out
  exit
 route-map rm-internal permit 10
  set community 300
  exit
 route-map rm-prov-in permit 10
  set local-preference 100
  set community 100
  exit
 route-map rm-prov-out permit 10
  match community cl-clients
  exit
 ip community-list standard cl-clients permit 300
 exit
{% endfoldhl %}

### AS9-3

{% foldhl text linenos %}
 enable
 configure terminal
 router bgp 9
  network 9.0.0.0 route-map rm-internal
  neighbor 100.0.79.7 route-map rm-prov-in in
  neighbor 100.0.79.7 route-map rm-prov-out out
  exit
 route-map rm-internal permit 10
  set community 300
  exit
 route-map rm-prov-in permit 10
  set local-preference 100
  set community 100
  exit
 route-map rm-prov-out permit 10
  match community cl-clients
  exit
 ip community-list standard cl-clients permit 300
 exit
{% endfoldhl %}

### AS10

{% foldhl text linenos %}
 enable
 configure terminal
 router bgp 10
  neighbor 100.0.0.2 route-map rm-prov-in in
  neighbor 100.0.0.6 route-map rm-prov-in in
  neighbor 100.0.0.9 route-map rm-prov-in in
  exit
 route-map rm-prov-in permit 10
  set community local-AS
  exit
 exit
{% endfoldhl %}

## Question 2.3

### Routes towards AS10

{% foldhl text linenos %}
 Step 0.
  AS10     has [10] (internal)
       advertises [10] to {2,6,9}
 Step 1. {2,6,9} received an advertisement
  AS2  now has [2,10] (customer)
       advertises [2,10] to {1,3,10}
                          - {10} (loops)
                          = {1,3}
  AS6  now has [6,10] (customer)
       advertises [6,10] to {3,5,10}
                          - {10} (loops)
                          = {3,5}
  AS9  now has [9,10] (customer)
       advertises [9,10] to {7,8,10}
                          - {10} (loops)
                          = {7,8}
 Step 2. {1,3,5,7,8} received an advertisement
  AS1  now has [1,2,10] (transit)
       advertises [1,2,10] to {2,3,4,5}
                            - {2,10} (loops)
                            - {2,3} (valley-free)
                            = {4,5}
  AS3  now has [3,6,10] (customer)
               [3,2,10] (transit)
       advertises [3,6,10] to {1,2,6}
                            - {6,10} (loops)
                            = {1,2}
  AS5  now has [5,6,10] (peering)
       advertises [5,6,10] to {1,6,8}
                            - {6,10} (loops)
                            - {1,6} (valley-free)
                            = {8}
  AS7  now has [7,9,10] (customer)
       advertises [7,9,10] to {4,9}
                            - {9,10} (loops)
                            = {4}
  AS8  now has [8,9,10] (customer)
       advertises [8,9,10] to {5,9}
                            - {9,10} (loops)
                            = {5}
 Step 3. {1,2,4,5,8} received an advertisement
  AS1  now has [1,3,6,10] (peering)
               [1,2,10] (transit)
       advertises [1,3,6,10] to {2,3,4,5}
                              - {3,6,10} (loops)
                              - {2,3} (valley-free)
                              = {4,5}
  AS2  now has [2,10] (customer)
               [2,3,6,10] (customer)
       does not advertise [2,10]
  AS4  now has [4,7,9,10] (customer)
               [4,1,2,10] (transit)
       advertises [4,7,9,10] to {1,7}
                              - {7,9,10} (loops)
                              = {1}
  AS5  now has [5,8,9,10] (customer)
               [5,6,10] (peering)
               [5,1,2,10] (transit)
       advertises [5,8,9,10] to {1,6,8}
                              - {8,9,10} (loops)
                              = {1,6}
  AS8  now has [8,9,10] (customer)
               [8,5,6,10] (transit)
       does not advertise [8,9,10]
 Step 4. {1,4,5,6} received an advertisement
  AS1  now has [1,4,7,9,10] (customer)
               [1,5,8,9,10] (customer)
               [1,3,6,10] (peering)
               [1,2,10] (transit)
       advertises [1,4,7,9,10] to {2,3,4,5}
                                - {4,7,9,10} (loops)
                                = {2,3,5}
  AS4  now has [4,7,9,10] (customer)
               [4,1,3,6,10] (transit) overrides [4,1,2,10]
       does not advertise [4,7,9,10]
  AS5  now has [5,8,9,10] (customer)
               [5,6,10] (peering)
               [5,1,3,6,10] (transit) overrides [5,1,2,10]
       does not advertise [5,8,9,10]
  AS6  now has [6,10] (customer)
               [6,5,8,9,10] (peering)
       does not advertise [6,10]
 Step 5. {2,3,5} received an advertisement
  AS2  now has [2,10] (customer)
               [2,3,6,10] (customer)
               [2,1,4,7,9,10] (customer)
       does not advertise [2,10]
  AS3  now has [3,6,10] (customer)
               [3,1,4,7,9,10] (peering)
               [3,2,10] (transit)
       does not advertise [3,6,10]
  AS5  now has [5,8,9,10] (customer)
               [5,6,10] (peering)
               [5,1,4,7,9,10] (transit) overrides [5,1,3,6,10]
       does not advertise [5,8,9,10]
{% endfoldhl %}

In the end, AS1 routes towards AS10 are

{% foldhl text linenos %}
 +-----+--------+------+
 | src | path   | dst  |
 +-----+--------+------+
 |     |> 4 7 9 |      |
 | AS1 |  5 8 9 | AS10 |
 |     |    3 6 |      |
 |     |      2 |      |
 +-----+--------+------+
{% endfoldhl %}

This can be checked in the BGP router of AS1.

{% foldhl text linenos %}
 AS1# sh ip bgp 10.0.0.0
 BGP routing table entry for 10.0.0.0/8, version 13
 BGP Bestpath: compare-routerid
 Paths: (4 available, best #1, table default)
   Advertised to update-groups:
      5          6          7
   Refresh Epoch 1
   4 7 9 10
     100.0.14.4 from 100.0.14.4 (4.4.4.4)
       Origin IGP, localpref 300, valid, external, best
       Community: 300
       rx pathid: 0, tx pathid: 0x0
   Refresh Epoch 1
   5 8 9 10
     100.0.15.5 from 100.0.15.5 (5.5.5.5)
       Origin IGP, localpref 300, valid, external
       Community: 300
       rx pathid: 0, tx pathid: 0
   Refresh Epoch 2
   2 10
     100.0.12.2 from 100.0.12.2 (2.2.2.2)
       Origin IGP, localpref 100, valid, external
       Community: 100
       rx pathid: 0, tx pathid: 0
   Refresh Epoch 1
   3 6 10
     100.0.13.3 from 100.0.13.3 (3.3.3.3)
       Origin IGP, localpref 200, valid, external
       Community: 200
       rx pathid: 0, tx pathid: 0
{% endfoldhl %}

### Routes towards AS1

{% foldhl text linenos %}
 Step 0.
  AS1      has [1] (internal)
       advertises [1] to {2,3,4,5}
 Step 1. {2,3,4,5} received an advertisement
  AS2  now has [2,1] (customer)
       advertises [2,1] to {1,3,10}
                         - {1} (loops)
                         = {3,10}
  AS3  now has [3,1] (peering)
       advertises [3,1] to {1,2,6}
                         - {1} (loops)
                         - {1,2} (valley-free)
                         = {6}
  AS4  now has [4,1] (transit)
       advertises [4,1] to {1,7}
                         - {1} (loops)
                         - {1} (valley-free)
                         = {7}
  AS5  now has [5,1] (transit)
       advertises [5,1] to {1,6,8}
                         - {1} (loops)
                         - {1,6} (valley-free)
                         = {8}
 Step 2. {3,6,7,8,10} received an advertisement
  AS3  now has [3,1] (peering)
               [3,2,1] (transit)
       does not advertise [3,1]
  AS6  now has [6,3,1] (transit)
       advertises [6,3,1] to {3,5,10}
                           - {3,1} (loops)
                           - {3,5} (valley-free)
                           = {10}
  AS7  now has [7,4,1] (transit)
       advertises [7,4,1] to {4,9}
                           - {4,1} (loops)
                           - {4} (valley-free)
                           = {9}
  AS8  now has [8,5,1] (transit)
       advertises [8,5,1] to {5,9}
                           - {5,1} (loops)
                           - {5} (valley-free)
                           = {9}
  AS10 now has [10,2,1] (transit)
       advertises [10,2,1] to {2,6,9}
                            - {2,1} (loops)
                            - {2,6,9} (valley-free)
                            = {}
 Step 3. {9,10} received an advertisement
  AS9  now has [9,7,4,1] (transit)
               [9,8,5,1] (transit)
       advertises [9,7,4,1] to {7,8,10}
                             - {7,4,1} (loops)
                             - {7,8} (valley-free)
                             = {10}
  AS10 now has [10,2,1] (transit)
               [10,6,3,1] (transit)
       does not advertise [10,2,1]
 Step 4. {10} received an advertisement
  AS10 now has [10,2,1] (transit)
               [10,6,3,1] (transit)
               [10,9,7,4,1] (transit)
       does not advertise [10,2,1]
{% endfoldhl %}

In the end, AS10 routes towards AS1 are

{% foldhl text linenos %}
 +------+--------+-----+
 | src  | path   | dst |
 +------+--------+-----+
 |      |>     2 |     |
 | AS10 |    6 3 | AS1 |
 |      |  9 7 4 |     |
 +------+--------+-----+
{% endfoldhl %}

This can be checked in the BGP router of AS10.

{% foldhl text linenos %}
 AS10# sh ip bgp 1.0.0.0
 BGP routing table entry for 1.0.0.0/8, version 23
 BGP Bestpath: compare-routerid
 Paths: (3 available, best #3, table default, not advertised outside local AS)
   Not advertised to any peer
   Refresh Epoch 1
   6 3 1
     100.0.0.6 from 100.0.0.6 (6.6.6.6)
       Origin IGP, localpref 100, valid, external
       Community: local-AS
       rx pathid: 0, tx pathid: 0
   Refresh Epoch 2
   9 7 4 1
     100.0.0.9 from 100.0.0.9 (9.9.9.1)
       Origin IGP, localpref 100, valid, external
       Community: local-AS
       rx pathid: 0, tx pathid: 0
   Refresh Epoch 3
   2 1
     100.0.0.2 from 100.0.0.2 (2.2.2.2)
       Origin IGP, localpref 100, valid, external, best
       Community: local-AS
       rx pathid: 0, tx pathid: 0x0
{% endfoldhl %}

### Route from AS8 to AS10

According to the detailed theoretical propagation of routes towards AS10,
routes in AS8 should be

{% foldhl text linenos %}
 +-----+------+------+
 | src | path | dst  |
 +-----+------+------+
 | AS8 |>   9 | AS10 |
 |     |  5 6 |      |
 +-----+------+------+
{% endfoldhl %}

Actually, there is only one route in the router of AS8.

{% foldhl text linenos %}
 AS8# sh ip bgp 10.0.0.0
 BGP routing table entry for 10.0.0.0/8, version 46
 BGP Bestpath: compare-routerid
 Paths: (1 available, best #1, table default)
   Advertised to update-groups:
      2
   Refresh Epoch 2
   9 10
     100.0.89.9 from 100.0.89.9 (9.9.9.2)
       Origin IGP, localpref 300, valid, external, best
       Community: 300
       rx pathid: 0, tx pathid: 0x0
{% endfoldhl %}

This is because before advertising a new route to its neighbours, a BGP router
will first advertise to every neighbour (no filter) the fact that it is removing
the old route.

## Question 2.4

Internal BGP settings (OSPF settings, actually) in router `AS9.4` consider the
link `AS9.4-AS9.3` to cost less than `AS9.4-AS9.2`. This forces the choice of
`AS7` without having to tie break because of Hot potato.

## Question 2.5

Choice of `AS8` as a next hop can be forced by configuring `AS9.4`.

{% foldhl text linenos %}
 enable
 configure terminal
 interface GigabitEthernet0/2
  ip ospf cost 12
  exit
 exit
{% endfoldhl %}
