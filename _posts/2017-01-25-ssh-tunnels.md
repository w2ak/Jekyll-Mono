---
layout: post
title: SSH tunnels
author: Clément Durand
category:
 - computer-science
 - notes
toc: true
---

*Howto notes about opening and using ssh tunnels.*

---

## Connecting somewhere through a ssh tunnel

*Describes a connection from `neze` to `peugeot` assuming you have ssh access to `deiz`. Useful if `peugeot` is accessible from `deiz` but not from `neze`.*

Modify your `.ssh/config` file.
```
Host peugeot
  HostName peugeot.polytechnique.fr
  Port 22
  User clement.durand
  ProxyCommand ssh -W %h:%p deiz
```

```sh
neze@neze ~$ ssh peugeot
```

## Reverse tunneling

*Describes a connection from `neze` to `peugeot` assuming you have ssh access to `vps`. Useful when `peugeot` and `neze` can access `vps` but `vps` cannot access them.*

On the machine you want to access, start a reverse tunnel.

```sh
clement.durand@peugeot ~$ ssh -NR 12345:localhost:22 vps
```

On your computer, setup the connection to go through vps.

```
Host peugeot
  HostName localhost
  Port 12345
  User clement.durand
  ProxyCommand ssh -W %h:%p vps
```

```sh
neze@neze ~$ ssh peugeot
```

## Tunneling

*Describes a connection from `local` to `peugeot` through `deiz` assuming you have ssh access to `deiz`, `peugeot` is only accessible from `deiz`, and the user willing to connect to `peugeot` doesn't have ssh access to `deiz`.*

On the proxy, setup a forwarding.

```sh
neze@deiz ~$ ssh -NL 0.0.0.0:12345:peugeot.polytechnique.fr:22 neze@localhost
```

On the user's computer, setup the connection to go through deiz.

```
Host peugeot
  HostName deiz
  Port 12345
  User user
```

```sh
user@local ~$ ssh peugeot
```

## Creating a socks proxy

*Describe access to a website from `neze`, assuming the website is only accessible from `deiz` and you have ssh access to `deiz`.*

On your machine, set up a socks proxy through the distant machine.

```sh
neze@neze ~$ ssh -ND 127.0.0.1:8080 deiz
```

Then, configure your browser to use a **socks 5 proxy on 127.0.0.1:8080**, with **remote DNS**. You will be able to access any website accessible from the distant machine.
