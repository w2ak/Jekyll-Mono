---
layout: post
title: SSH and pipelines
category: computer-science
author: Clément Durand
---

A few tips about combining pipelines and ssh.

## Tared scp

Faster when you have many files.

```sh
neze@neze ~$ tar czf - *.txt | ssh vps 'tar xzf -'
```

## Other operations

```sh
neze@neze ~$ ssh vps 'cat .ssh/id_rsa.pub' | ssh peugeot 'cat - >> .ssh/authorized_keys'
```
