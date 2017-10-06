---
layout: post
title: BGP Practical
toc: true
author: Carolina De Senne
date: 2017-05-10
permalink: /acn/bgp-practical/carolina.html
back: /acn/

---

# TP BGP

## Multi-Homed Network (AS10)

### Question 1.1
In order to **prohibit transit** through AS10, we have to configure the local bgp route maps by defining that every **incoming route** should be **used only by the local-AS**, and not advertised. This is done to every neighbour AS (2,6 and 9), as follows:

First, define the route-map:

```
AS10> enable
AS10# configure terminal
AS10(config)# router bgp 10
AS10(config-router)# neighbor 100.0.0.2 remote-as 2
AS10(config-router)# neighbor 100.0.0.2 route-map rm-prov-in in
AS10(config-router)# neighbor 100.0.0.6 remote-as 6
AS10(config-router)# neighbor 100.0.0.6 route-map rm-prov-in in
AS10(config-router)# neighbor 100.0.0.9 remote-as 9
AS10(config-router)# neighbor 100.0.0.9 route-map rm-prov-in in
AS10(config-router)# exit
AS10(config)#
```

Then, tell the router that this route-map should be used internally in the AS:

```
  AS10(config)# route-map rm-prov-in permit 10
  AS10(config-route-map)# set community local-AS
  AS10(config-route-map)# exit
  AS10(config)#
```

### Question 1.2
Here we must not mix up the concepts of **outgoing traffic** and **outgoing routes**. In order to choose the outgoing traffic path, we should **set preferences** to the **incoming** bgp routes (setting a lower preference to AS2, since we want to avoid this route).

Let's define different route-maps for each AS neighbor:

```
AS10(config-router)# neighbor 100.0.0.2 route-map rm-prov2-in in
AS10(config-router)# neighbor 100.0.0.6 route-map rm-prov6-in in
AS10(config-router)# neighbor 100.0.0.9 route-map rm-prov9-in in
```

Let's set them with different preferences:

```
AS10(config)# route-map rm-prov2-in permit 10
AS10(config-route-map)# set community local-AS
AS10(config-route-map)# set local-preference 100
...
AS10(config)# route-map rm-prov6-in permit 10
AS10(config-route-map)# set community local-AS
AS10(config-route-map)# set local-preference 200
...
AS10(config)# route-map rm-prov9-in permit 10
AS10(config-route-map)# set community local-AS
AS10(config-route-map)# set local-preference 200
```

### Question 1.3

We want to control the **incoming traffic**, which means we want to control which path other AS's will choose to get to AS10. In order to do so, we have to trick the network and **advertise a longer path** through AS2 than it actually is. We do this by setting up an **outgoing route-map** and adding the AS10 several times to AS2 bgp path.

```
AS10(config-router)# neighbor 100.0.0.2 route-map rm-prov2-out out
...
AS10(config)# route-map rm-prov2-out permit 10
AS10(config-route-map)# set as-path prepend 10 10 10 10
```

### Question 1.4
In real life one cannot force others to do things if they do not want to. In bgp the same applies: even if AS10 advertises a longer path through AS2, other AS's can **set high preferences** (see question 1.2) to their incoming routes from AS2, so that the traffic will necessarily pass through it. This way, other AS's could bypass the filters applied by AS10 (when prepending itself to AS2 outgoing route path).

## Carriers
### Question 2.1
There are **two main reasons** why not all possible paths can be known by all ASs.
The first is that in the naive shortest-path protocol, every AS only **advertises it's own shortest path** to its' neighbors.

For example, **AS5 has the following paths to AS10**:

```
*> 5 -> 6 -> 10
*  5 -> 8 -> 9 -> 10
*  5 -> 1 -> 3 -> 6 -> 10
```

So it **will only advertise the first one**, since it's the shortest. Hence, AS1 won't see the second paths through AS5, AS8, AS9 to AS10. The second reason is **poisoned-reverse**: one does not advertise a route to a neighbor from whom it has received this very same route (we want to avoid loops!). This is why AS1 won't see the third path indicated in AS5 path list to AS10.

The possible paths seen by **AS1 towards AS10** are then:

```
*> 1 -> 3 -> 6 -> 10
*  1 -> 5 -> 6 -> 10
*  1 -> 2 -> 3 -> 6 -> 10
*  1 -> 4 -> 7 -> 9 -> 10
```

### Question 2.2

In this question we want to configure the bgp routers in order to respect the usual commercial routing policies: **customer/peering/transit preferences** and **“valley free”**. We exemplify what has to be done for **AS1 bgp router**, since the other router configurations are equivalent if we respect the custome/peer/transit relationships.

First of all, we create different incoming and outgoing **route maps** for providers (AS2), peers (AS3) and customers (AS4 and AS5):

```
AS1(config-router)# neighbor 100.0.0.2 route-map rm-prov-in in
AS1(config-router)# neighbor 100.0.0.2 route-map rm-prov-out out
AS1(config-router)# neighbor 100.0.0.3 route-map rm-peer-in in
AS1(config-router)# neighbor 100.0.0.3 route-map rm-peer-out out
AS1(config-router)# neighbor 100.0.0.4 route-map rm-cust-in in
AS1(config-router)# neighbor 100.0.0.4 route-map rm-cust-out out
AS1(config-router)# neighbor 100.0.0.5 route-map rm-cust-in in
AS1(config-router)# neighbor 100.0.0.5 route-map rm-cust-out out
```

Then, we have to **define local preferences to the incoming routes** so that the most prefered routes are those from the clients, then the peers and as a last option, the providers. We also define here the **communities of incoming routes**, which are going to be usefull when filtering the outgoing routes:

```
AS1(config)# route-map rm-prov-in permit 10
AS1(config-route-map)# set local-preference 100
AS1(config-route-map)# set community 100
...
AS1(config)# route-map rm-peer-in permit 10
AS1(config-route-map)# set local-preference 200
AS1(config-route-map)# set community 200
...
AS1(config)# route-map rm-cust-in permit 10
AS1(config-route-map)# set local-preference 300
AS1(config-route-map)# set community 300
```

Now we need to define **community lists for the outgoing routes** (those which are advertised to specific neighbors), that **match specific communities**. The outgoing routes to the customers must match every community (since we want to advertise every possible route to the client). However, peers and providers must only know about customer incoming routes. This can be done as follows:

```
AS1(config)# ip community-list standard customer permit 300
AS1(config)# ip community-list standard all permit 100
AS1(config)# ip community-list standard all permit 200
AS1(config)# ip community-list standard all permit 300
```

And last, but not least, we need to tell the router which lists should be matched for the outgoing routes:

```
AS1(config)# route-map rm-prov-out permit 10
AS1(config-route-map)# match community customer
...
AS1(config)# route-map rm-peer-out permit 10
AS1(config-route-map)# match community customer
...
AS1(config)# route-map rm-cust-out permit 10
AS1(config-route-map)# match community all
```

### Question 2.3

The possible paths seen by **AS10 towards AS1** are the following:

```
*> 10 -> 2 -> 1
*  10 -> 6 -> 3 -> 1
*  10 -> 9 -> 8 -> 5 -> 1
```

And since AS2, AS6 and AS9 are all providers for AS10, the last one chooses the **shortest path available** (also because we haven't set up any local preferences). AS2 then chooses the path directly to AS1, since it is a customer.

The possible paths seen by **AS1 towards AS10** are the following:

```
*> 1 -> 4 -> 7 -> 9 -> 10
*  1 -> 5 -> 8 -> 9 -> 10
*  1 -> 3 -> 6 -> 10
*  1 -> 2 -> 10
```

AS1 prefers the paths through it's clients, hence 4 and 5. We have no preference between those two, so it chooses the smallest one. Then, AS4, AS7 and AS9 choose the **paths though their clients** that lead to AS10.

When we take a look at the paths seen by **AS8 towards AS10**, we have the following:

```
*> 8 -> 9 -> 10
```

And nothing else. This might seem weird in a first look, since the path

```
* 8 -> 5 -> 6 -> 10
```

would be also a valid one... However, **AS5 only advertises it's preferred path to AS8**, which passes through AS8 (client first!): by the **poisoned-reverse** rule, this path is not advertised, so AS8 only knows the path through AS9.
