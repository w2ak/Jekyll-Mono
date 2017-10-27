---
layout: post
toc: true
title: Télécom ParisTech access
author: Clément Durand
---

*Access to the Télécom ParisTech network.*

---

# Notations

I will use `<username>` to denote the LDAP username, and `<password>` the corresponding password.

In my case, then I have the following:

{% hl text %}
 username="cdurand"
 password="¿?¿?¿?¿?"
{% endhl %}

# SSH Access

## Out-of-the-box access

You can use [this script][https://gist.github.com/w2ak/cf307845e554ac713723dbe125f58bdd] to access shells from Télécom ParisTech machines.

The code is not perfect and could be improved, **dont hesitate to write comments on the github page if you have suggestions**.

Please note that basic help is available by executing `./ssh.sh -h`.

## Shell access

Simple shell access can be performed through `ssh.enst.fr`.

{% hl text %}
 neze@yoga ~ $ ssh <username>@ssh.enst.fr
 <username>@ssh.enst.fr's password:
 ssh1%
{% endhl %}

You will end up randomly on `ssh1` or `ssh2` (with your same old home folder whatever the machine).

## Access to a computer

You can access any computer in a lab, provided it is switched on. The examples will be made with `c129-21`, i.e., computer 21 from room 129 in the C building.

{% hl text %}
 neze@yoga ~ $ ssh <username>@ssh.enst.fr
 <username>@ssh.enst.fr's password:
 ssh1% ssh c129-21
 <username>@c129-21's password:
 c129-21%
{% endhl %}

## Direct access

To avoid having to call every ssh command, and easily add new rooms to your configuration, you can edit your `ssh` config file (generally found in `~/.ssh/config`).

{% hl text %}
 neze@yoga ~ $ mkdir -p ~/.ssh
 neze@yoga ~ $ $EDITOR ~/.ssh/config
{% endhl %}

{% foldhl diff linenos %}
+Host enst room
+  User <username>
+
+Host enst
+  HostName ssh.enst.fr
+
+Host room
+  HostName c129-21.enst.fr
+  ProxyCommand ssh -W %h:%p enst
{% endfoldhl %}

{% hl text %}
 neze@yoga ~ $ ssh room
 <username>@enst's password:
 <username>@room's password:
 c129-21%
{% endhl %}

## Using a key

Using a key avoids having to type the password every time and is more secure.

You can (if you don't already have one) generate a key. ***If you do not trust
your computer's safety or if you intend to use this key for critical accesses,
please make sure not to use an empty passphrase.***

{% foldhl text %}
 neze@yoga ~ $ ssh-keygen -t ecdsa -b 521
 Generating public/private ecdsa key pair.
 Enter file in which to save the key (~/.ssh/id_ecdsa):
 Enter passphrase (empty for no passphrase):
 Enter same passphrase again:
 Your identification has been saved in ~/.ssh/id_ecdsa.
 Your public key has been saved in ~/.ssh/id_ecdsa.pub.
 The key fingerprint is:
 SHA256:RFvkT4zJm42yqK8Y5Ju2Pkk4napTH8NgnGK/DW6flO8 neze@neze-yoga
 The key's randomart image is:
 +---[ECDSA 521]---+
 |        ..o      |
 |       . = +     |
 | . .    o = o    |
 |..=    .   B     |
 |.=o+    S + o    |
 |oo=o+ .. o       |
 | =+o+=. .        |
 |o +Oooo          |
 |o+Bo+=oE         |
 +----[SHA256]-----+
{% endfoldhl %}

Then you have to copy the **public** key to Télécom. Do not copy this file manually, use `ssh-copy-id` as below.

{% foldhl text %}
 neze@yoga ~ $ ssh-copy-id -i ~/.ssh/id_ecdsa.pub enst
 /usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "~/.ssh/id_ecdsa.pub"
 /usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
 /usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
 
 <username>@enst's password:
 
 Number of key(s) added: 1
 
 Now try logging into the machine, with:   "ssh 'enst'"
 and check to make sure that only the key(s) you wanted were added.
{% endfoldhl %}

Finally, make sure that your ssh config file always use the right key by modifying `~/.ssh/config` as follows.

{% foldhl diff linenos %}
 Host enst room
   User <username>
+  IdentityFile ~/.ssh/id_ecdsa
 
 Host enst
   HostName ssh.enst.fr
 
 Host room
   HostName c129-21.enst.fr
   ProxyCommand ssh -W %h:%p enst
{% endfoldhl %}

Now, connection to `room` should be rather direct.

{% hl text %}
 neze@yoga ~ $ ssh room
 c129-21%
{% endhl %}

## Accessing graphical interfaces

Graphical interfaces access can be tricky when you have to go through an
intermediate server (here, `enst` or `ssh.enst.fr`). The configuration file
however allows you to do this pretty easily. Now that you configured everything
you can easily access graphical interfaces of `room`.

{% hl text %}
 neze@yoga ~ $ ssh -X room
 c129-21% eclipse          # or chromium, for example
{% endhl %}

# Tunnelling

![ieee](http://pix.toile-libre.org/upload/original/1509094362.png){:style="float:left;margin:0 10px 0 0"}

A basic use-case of tunnels is getting access to scientific paper websites like IEEE.

Assuming that you configured your ssh client, you should be able to open a socks proxy:

{% hl text %}
 neze@yoga ~ $ ssh -ND 8080 room

{% endhl %}

Do not close this terminal, then configure your web browser to use the SOCKS5 proxy
`127.0.0.1:8080`. On firefox, this is found in the `Preferences` page, `Advanced`
section, under the `Network` tab. There is a `Settings` button to setup *how Firefox
connects to the Internet*, and it includes a proxy configuration.

More information about SSH connections and tunnels can be found in
[this article]({% link _posts/2017-01-25-ssh-connexions-and-tunnels.md %}) or on the web.
