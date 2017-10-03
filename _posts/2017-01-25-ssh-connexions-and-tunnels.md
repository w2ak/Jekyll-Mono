---
layout: post
title: SSH connexions and tunnels
author: Clément Durand
category:
 - computer-science
 - notes
toc: true
---

*Howto notes about opening and using ssh and ssh tunnels.*

---

## Setting up a server

*Describes the setup of a shortcut `deiz` to some server. Useful to avoid typing the whole ssh command each time.*

Assume that you use the following command to connect to deiz:
```sh
neze@neze ~$ ssh -p12345 -oIdentityFile=~/.ssh/deiz_ecdsa me@deiz.domain.fr
```

Modify your `.ssh/config` file.
```
Host deiz
  HostName deiz.domain.fr
  Port 12345
  User me
  IdentityFile ~/.ssh/deiz_ecdsa
```

Then you'll be able to connect to `deiz` with the command:
```sh
neze@neze ~$ ssh deiz
```

## Connecting somewhere through a ssh tunnel

*Describes a connection from `neze` to `peugeot` assuming you have ssh access to `deiz`. Useful if `peugeot` is accessible from `deiz` but not from `neze`.*

Note that you could do this without any new setup with the following ssh command
```sh
neze@neze ~$ ssh -J deiz clement.durand@peugeot.polytechnique.fr
```

Modify your `.ssh/config` file.
```
Host peugeot
  HostName peugeot.polytechnique.fr
  Port 22
  User clement.durand
  ProxyCommand ssh -W %h:%p deiz
```

You can eventually replace the `ProxyCommand` instruction with
```
  ProxyJump deiz
```
which actually allows you to setup multiple jumps separated by commas.

```sh
neze@neze ~$ ssh peugeot
```

## Port forwarding

### Reverse tunneling

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

### Tunneling

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

### Creating a socks proxy

*Describe access to a website from `neze`, assuming the website is only accessible from `deiz` and you have ssh access to `deiz`.*

On your machine, set up a socks proxy through the distant machine.

```sh
neze@neze ~$ ssh -ND 127.0.0.1:8080 deiz
```

Then, configure your browser to use a **socks 5 proxy on 127.0.0.1:8080**, with **remote DNS**. You will be able to access any website accessible from the distant machine.

### Notes about the -N option

The previous sections about port forwarding use the `-N` option of ssh. This is useful if you do not want a remote terminal but only to setup a tunnel with port forwarding.

If you also want access to a remote terminal, no need to connect twice to the same server, you can remove the `-N` option:
```sh
neze@neze ~$ ssh -D 127.0.0.1:8080 deiz
```

If you do not want a remote terminal, you can also put this process in background with one of the following methods.
```sh
neze@neze ~$ screen -S deiztunnel ssh -ND 127.0.0.1:8080 deiz
neze@neze ~$ exit
# then later when you want to stop the tunnel
neze@neze ~$ screen -r deiztunnel
^C
[screen is terminating]
neze@neze ~$ exit
```
```sh
neze@neze ~$ ssh -ND 127.0.0.1:8080 deiz &
[1] 20043
neze@neze ~$ disown
neze@neze ~$ exit
# then later when you want to stop the tunnel
neze@neze ~$ kill 20043
```
