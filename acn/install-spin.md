---
layout: post
title: ACN Master
author: Clément Durand
date: 2017-09-15
permalink: /acn/spin/
---

The instructions are on [SpinRoot](http://spinroot.com/).

# Unix instructions

## Download Spin

Download the latest source from the [distribution](http://spinroot.com/spin/Src/index.html) page.

```
Full distribution, with sources: spin647.tar.gz (476k)
```

## Setup a user bin folder

Create your bin folder and setup your terminal to make it aware of the path

```sh
neze@neze.fr ~$ mkdir bin
neze@neze.fr ~$ echo 'export PATH=$PATH:/home/neze/bin/' >> .bashrc
```

## Compile

Move and compile the source files

```sh
neze@neze.fr ~$ cd Downloads
neze@neze.fr ~/Downloads$ gunzip Spin647.tar.gz
neze@neze.fr ~/Downloads$ tar xzf Spin647.tar
neze@neze.fr ~/Downloads$ mv Spin ~/bin/

neze@neze.fr ~$ make -C bin/Spin/Src6.4.7
neze@neze.fr ~$ ln -s /home/neze/bin/Spin/Src6.4.7/spin /home/neze/bin/spin
```

Restart your terminal to check the install

```
neze@neze.fr ~$ which spin
/home/neze/bin/spin
```

## Install the man pages

Create a link to the man page and update the man database.

```
neze@neze.fr ~$ sudo ln -s /home/neze/bin/Spin/Man/spin.1 /usr/local/share/man/man1/spin.1
neze@neze.fr ~$ sudo mandb
```
