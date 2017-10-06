---
layout: post
title: BGP Initial configuration
toc: true
author: Clément Durand
date: 2017-10-05
permalink: /acn/bgp-practical/config.html
back: /acn/

---

*To apply this initial configuration, open the terminal of the correct router,
type `Enter` then paste the code.*

# AS1

{% hl text linenos %}
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
{% endhl %}

# AS2

{% hl text linenos %}
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
{% endhl %}

# AS3

{% hl text linenos %}
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
{% endhl %}

# AS4

{% hl text linenos %}
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
{% endhl %}

# AS5

{% hl text linenos %}
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
{% endhl %}

# AS6

{% hl text linenos %}
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
{% endhl %}

# AS7

{% hl text linenos %}
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
{% endhl %}

# AS8

{% hl text linenos %}
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
{% endhl %}

# AS9

## AS9-1

{% hl text linenos %}
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
{% endhl %}

## AS9-2

{% hl text linenos %}
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
{% endhl %}

## AS9-3

{% hl text linenos %}
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
{% endhl %}

## AS9-4

{% hl text linenos %}
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
{% endhl %}

# AS10

{% hl text linenos %}
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
{% endhl %}

