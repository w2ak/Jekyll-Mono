---
layout: post
title: Linux networking
author: Clément Durand
category:
 - computer-science
 - notes
toc: true
---

*A few notes about interfaces manipulations, general networking, etc.*

---

# Interfaces manipulations

## Setting up a bridge

Assume you have two interfaces `eth0` and `eth1` and you want to put them on the same link.

```sh
# With ip link

ip link add name br0 type bridge
ip link set br0 up
ip link set eth0 up
ip link set eth0 master br0
ip link set eth1 up
ip link set eth1 master br0

ip link set eth1 nomaster
ip link set eth1 down
ip link set eth0 nomaster
ip link set eth0 down
ip link delete br0 type bridge

# With brctl from bridge-utils

brctl addbr br0
brctl addif br0 eth0
brctl addif br0 eth1
ip link set br0 up

ip link set br0 down
brctl delbr br0
```

# Simple servers and clients

## Using socat

Echo server listening on one port and answering exactly what it receives.
The `fork` instruction allows it to fork and accept multiple connections.

```sh
socat TCP4-LISTEN:$PORT,fork EXEC:'/bin/cat'
```

# Network file systems

## SSH filesystem

How to locally mount a remote folder.

```sh
sshfs -o IdentityFile=$ID $SSH_DIR -o volname=$VOLUME -o auto_cache,reconnect,defer_permissions,noappledouble,nolocalcaches,no_readahead $MOUNT_DIR -o exec
```
