---
layout: post
permalink: /acn/bgp/new.html
---

# Initial config

## AS1

{% foldhl text linenos %}
 enable
 configure terminal
 hostname AS1
 router bgp 1
  bgp router-id 1.1.1.1
  bgp log-neighbor-changes
  bgp bestpath compare-routerid
  network 1.0.0.0
  neighbor 100.0.12.2 remote-as 2
  neighbor 100.0.13.3 remote-as 3
  neighbor 100.0.14.4 remote-as 4
  neighbor 100.0.15.5 remote-as 5
  exit
 exit
 copy running-config startup-config
{% endfoldhl %}

## AS2

{% foldhl text linenos %}
 enable
 configure terminal
 hostname AS2
 router bgp 2
  bgp router-id 2.2.2.2
  bgp log-neighbor-changes
  bgp bestpath compare-routerid
  network 2.0.0.0
  neighbor 100.0.0.10 remote-as 10
  neighbor 100.0.12.1 remote-as 1
  neighbor 100.0.23.3 remote-as 3
  exit
 exit
 copy running-config startup-config
{% endfoldhl %}

## AS3

{% foldhl text linenos %}
 enable
 configure terminal
 hostname AS3
 router bgp 3
  bgp router-id 3.3.3.3
  bgp log-neighbor-changes
  bgp bestpath compare-routerid
  network 3.0.0.0
  neighbor 100.0.13.1 remote-as 1
  neighbor 100.0.23.2 remote-as 2
  neighbor 100.0.36.6 remote-as 6
  exit
 exit
 copy running-config startup-config
{% endfoldhl %}

## AS4

{% foldhl text linenos %}
 enable
 configure terminal
 hostname AS4
 router bgp 4
  bgp router-id 4.4.4.4
  bgp log-neighbor-changes
  bgp bestpath compare-routerid
  network 4.0.0.0
  neighbor 100.0.14.1 remote-as 1
  neighbor 100.0.47.7 remote-as 7
  exit
 exit
 copy running-config startup-config
{% endfoldhl %}

## AS5

{% foldhl text linenos %}
 enable
 configure terminal
 hostname AS5
 router bgp 5
  bgp router-id 5.5.5.5
  bgp log-neighbor-changes
  bgp bestpath compare-routerid
  network 5.0.0.0
  neighbor 100.0.15.1 remote-as 1
  neighbor 100.0.56.6 remote-as 6
  neighbor 100.0.58.8 remote-as 8
  exit
 exit
 copy running-config startup-config
{% endfoldhl %}

## AS6

{% foldhl text linenos %}
 enable
 configure terminal
 hostname AS6
 router bgp 6
  bgp router-id 6.6.6.6
  bgp log-neighbor-changes
  bgp bestpath compare-routerid
  network 6.0.0.0
  neighbor 100.0.0.10 remote-as 10
  neighbor 100.0.36.3 remote-as 3
  neighbor 100.0.56.5 remote-as 5
  exit
 exit
 copy running-config startup-config
{% endfoldhl %}

## AS7

{% foldhl text linenos %}
 enable
 configure terminal
 hostname AS7
 router bgp 7
  bgp router-id 7.7.7.7
  bgp log-neighbor-changes
  bgp bestpath compare-routerid
  network 7.0.0.0
  neighbor 100.0.47.4 remote-as 4
  neighbor 100.0.79.9 remote-as 9
  exit
 exit
 copy running-config startup-config
{% endfoldhl %}

## AS8

{% foldhl text linenos %}
 enable
 configure terminal
 hostname AS8
 router bgp 8
  bgp router-id 8.8.8.8
  bgp log-neighbor-changes
  bgp bestpath compare-routerid
  network 8.0.0.0
  neighbor 100.0.58.5 remote-as 5
  neighbor 100.0.89.9 remote-as 9
  exit
 exit
 copy running-config startup-config
{% endfoldhl %}

## AS9

### AS9-1

{% foldhl text linenos %}
 enable
 configure terminal
 hostname AS9-1
 mpls label protocol ldp
 no mpls ip propagate-ttl
 router ospf 9
  network 9.0.0.0 0.255.255.255 area 0
  network 100.9.0.0 0.0.255.255 area 0
  exit
 router bgp 9
  bgp router-id 9.9.9.1
  bgp log-neighbor-changes
  bgp bestpath compare-routerid
  network 9.0.0.0
  neighbor 9.9.9.2 remote-as 9
  neighbor 9.9.9.2 update-source Loopback0
  neighbor 9.9.9.2 next-hop-self
  neighbor 9.9.9.2 send-community
  neighbor 9.9.9.3 remote-as 9
  neighbor 9.9.9.3 update-source Loopback0
  neighbor 9.9.9.3 next-hop-self
  neighbor 9.9.9.3 send-community
  neighbor 100.0.0.10 remote-as 10
  exit
 mpls ldp router-id Loopback0
 exit
 copy running-config startup-config
{% endfoldhl %}

### AS9-2

{% foldhl text linenos %}
 enable
 configure terminal
 hostname AS9-2
 mpls label protocol ldp
 no mpls ip propagate-ttl
 router ospf 9
  network 9.0.0.0 0.255.255.255 area 0
  network 100.9.0.0 0.0.255.255 area 0
  exit
 router bgp 9
  bgp router-id 9.9.9.2
  bgp log-neighbor-changes
  bgp bestpath compare-routerid
  network 9.0.0.0
  neighbor 9.9.9.1 remote-as 9
  neighbor 9.9.9.1 update-source Loopback0
  neighbor 9.9.9.1 next-hop-self
  neighbor 9.9.9.1 send-community
  neighbor 9.9.9.3 remote-as 9
  neighbor 9.9.9.3 update-source Loopback0
  neighbor 9.9.9.3 next-hop-self
  neighbor 9.9.9.3 send-community
  neighbor 100.0.89.8 remote-as 8
  exit
 mpls ldp router-id Loopback0
 exit
 copy running-config startup-config
{% endfoldhl %}

### AS9-3

{% foldhl text linenos %}
 enable
 configure terminal
 hostname AS9-3
 mpls label protocol ldp
 no mpls ip propagate-ttl
 router ospf 9
  network 9.0.0.0 0.255.255.255 area 0
  network 100.9.0.0 0.0.255.255 area 0
  exit
 router bgp 9
  bgp router-id 9.9.9.3
  bgp log-neighbor-changes
  bgp bestpath compare-routerid
  network 9.0.0.0
  neighbor 9.9.9.1 remote-as 9
  neighbor 9.9.9.1 update-source Loopback0
  neighbor 9.9.9.1 next-hop-self
  neighbor 9.9.9.1 send-community
  neighbor 9.9.9.2 remote-as 9
  neighbor 9.9.9.2 update-source Loopback0
  neighbor 9.9.9.2 next-hop-self
  neighbor 9.9.9.2 send-community
  neighbor 100.0.79.7 remote-as 7
  exit
 mpls ldp router-id Loopback0
 exit
 copy running-config startup-config
{% endfoldhl %}

### AS9-4

{% foldhl text linenos %}
 enable
 configure terminal
 hostname AS9-4
 multilink bundle-name authenticated
 mpls label protocol ldp
 router ospf 9
  network 9.0.0.0 0.255.255.255 area 0
  network 100.9.0.0 0.0.255.255 area 0
  exit
 mpls ldp router-id Loopback0
 exit
 copy running-config startup-config
{% endfoldhl %}

## AS10

{% foldhl text linenos %}
 enable
 configure terminal
 hostname AS10
 router bgp 10
  bgp router-id 10.10.10.10
  bgp log-neighbor-changes
  bgp bestpath compare-routerid
  network 10.0.0.0
  neighbor 100.0.0.2 remote-as 2
  neighbor 100.0.0.6 remote-as 6
  neighbor 100.0.0.9 remote-as 9
  exit
 exit
 copy running-config startup-config
{% endfoldhl %}

# Practical

## Multi-homed network

### Question 1.1

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

### Question 1.2

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

### Question 1.3

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

### Question 1.4

*How can the shaping applied by AS10 for the incoming traffic be bypassed by other ASs?*

Peers can still bypass path prepending with their local preferences.

### Questions 1.1-4 reset

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

## Carriers

### Question 2.1

Some AS do not see every possible route towards AS10 because, in the
advertisement process, every router only advertises its best path towards AS10.
For example, `1-5-8-9-10` will not be found in the table of AS1 because the best
path from AS5 to AS10 is actually `5-6-10`.

#### Theoretical routes advertisement

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

#### Check

This is confirmed by running the following in each AS BGP router.

{% foldhl text linenos %}
 enable
 show ip bgp all
{% endfoldhl %}

### Question 2.2

#### AS1

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

#### AS2

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

#### AS3

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

#### AS4

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

#### AS5

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

#### AS6

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

#### AS7

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

#### AS8

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

#### AS9-1

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

#### AS9-2

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

#### AS9-3

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

#### AS10

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

### Question 2.3

#### Routes towards AS10

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

#### Routes towards AS1

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

#### Route from AS8 to AS10

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

This is because the anti-loop filtering is not performed at sending but at
reception. This allowed AS8 (at step 4) to receive [5,8,9,10] from AS5, which
overrided [5,6,10] before beeing filtered out because of loops.

#### Correcting route propagation

Here is what the route propagation looks like when loop avoiding is done at
reception.

{% foldhl text linenos %}
 Step 0.
  AS10     has [10] (internal)
       advertises [10] to {2,6,9}
 Step 1. {2,6,9} received an advertisement
  AS2  now has [2,10] (customer)
       advertises [2,10] to {1,3,10}
  AS6  now has [6,10] (customer)
       advertises [6,10] to {3,5,10}
  AS9  now has [9,10] (customer)
       advertises [9,10] to {7,8,10}
 Step 2. {1,3,5,7,8,10} received an advertisement
  AS1  now has [1,2,10] (transit)
       advertises [1,2,10] to {2,3,4,5}
                            - {2,3} (valley-free)
                            = {4,5}
  AS3  now has [3,6,10] (customer)
               [3,2,10] (transit)
       advertises [3,6,10] to {1,2,6}
                            = {1,2,6}
  AS5  now has [5,6,10] (peering)
       advertises [5,6,10] to {1,6,8}
                            - {1,6} (valley-free)
                            = {8}
  AS7  now has [7,9,10] (customer)
       advertises [7,9,10] to {4,9}
                            = {4,9}
  AS8  now has [8,9,10] (customer)
       advertises [8,9,10] to {5,9}
                            = {5,9}
  AS10 now has [10] (internal)
               [10,2,10] (loop)
               [10,6,10] (loop)
               [10,9,10] (loop)
       now has [10] (internal)
       does not advertise [10]
 Step 3. {1,2,4,5,6,8,9} received an advertisement
  AS1  now has [1,3,6,10] (peering)
               [1,2,10] (transit)
       advertises [1,3,6,10] to {2,3,4,5}
                              - {2,3} (valley-free)
                              = {4,5}
  AS2  now has [2,10] (customer)
               [2,3,6,10] (customer)
       does not advertise [2,10]
  AS4  now has [4,7,9,10] (customer)
               [4,1,2,10] (transit)
       advertises [4,7,9,10] to {1,7}
                              = {1,7}
  AS5  now has [5,8,9,10] (customer)
               [5,6,10] (peering)
               [5,1,2,10] (transit)
       advertises [5,8,9,10] to {1,6,8}
                              = {1,6,8}
  AS6  now has [6,10] (customer)
               [6,3,6,10] (loop)
       now has [6,10] (customer)
       does not advertise [6,10]
  AS8  now has [8,9,10] (customer)
               [8,5,6,10] (transit)
       does not advertise [8,9,10]
  AS9  now has [9,10] (customer)
               [9,7,9,10] (loop)
               [9,8,9,10] (loop)
       does not advertise [9,10]
 Step 4. {1,4,5,6,7,8} received an advertisement
  AS1  now has [1,4,7,9,10] (customer)
               [1,5,8,9,10] (customer)
               [1,3,6,10] (peering)
               [1,2,10] (transit)
       advertises [1,4,7,9,10] to {2,3,4,5}
                                = {2,3,4,5}
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
  AS7  now has [7,9,10] (customer)
               [7,4,7,9,10] (loop)
       does not advertise [4,7,9,10]
  AS8  now has [8,9,10] (customer)
               [8,5,8,9,10] (loop) overrides [8,5,6,10]
       does not advertise [8,9,10]
 Step 5. {2,3,4,5} received an advertisement
  AS2  now has [2,10] (customer)
               [2,3,6,10] (customer)
               [2,1,4,7,9,10] (customer)
       does not advertise [2,10]
  AS3  now has [3,6,10] (customer)
               [3,1,4,7,9,10] (peering)
               [3,2,10] (transit)
       does not advertise [3,6,10]
  AS4  now has [4,7,9,10] (customer)
               [4,1,4,7,9,10] (loop) overrides [4,1,3,6,10]
       does not advertise [4,7,9,10]
  AS5  now has [5,8,9,10] (customer)
               [5,6,10] (peering)
               [5,1,4,7,9,10] (transit) overrides [5,1,3,6,10]
       does not advertise [5,8,9,10]
{% endfoldhl %}

In order to verify that this is correct, a good way is to check that there is
only one route towards AS10 in the table of AS4. Indeed, in the previous version
we had two routes at Step 5.
