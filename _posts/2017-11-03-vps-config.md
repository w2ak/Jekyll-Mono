---
layout: post
title: VPS First Configuration
category:
 - computer-science
 - notes
toc: true
author: Clément Durand
---

*How I would configure my vps for the first time. Instructions on a Debian host.*

---

I will call my computer **`laptop`**, my server **`server`** at the address
**`example.com`** with ip **`93.184.216.34`**.
On both sides my username will be **`neze`**.

# Initial setup of access

## Remove root ssh access

### Remove password root ssh access

  * Create an ssh key on `laptop`.

```sh
neze@laptop ~ % ssh-keygen -t ecdsa -b 521 -f ~/.ssh/id_example.com -C "neze@laptop"
# -t: cryptographic algorithm. Values: rsa,ecdsa,ed25519.
# -b: key size. Values: minimum 1024 for rsa (at least 2048 advised),
#     256 384 or 521 for ecdsa, no value for ed25519
```

*This command will ask for a passphrase. If you do not trust your laptop, choose a strong passphrase.*

  * Configure your laptop to correctly use the ssh key.

```sh
neze@laptop ~ % cat << EOF >> ~/.ssh/config
Host example.com
    HostName 93.184.216.34
    IdentityFile ~/.ssh/id_example.com
EOF
```

  * Copy the identity file to `root@server`.

```sh
neze@laptop ~ % ssh-copy-id -i ~/.ssh/id_example.com.pub root@example.com
# -i: Path to the public identity file.
```

  * Check that you can connect to `root@server` without password.

```sh
neze@laptop ~ % ssh root@example.com
```

Keep this shell open until you finish this part.

  * Disable password login for root.

```sh
root@server ~ % vi /etc/ssh/sshd_config
```

```diff
-PermitRootLogin yes
+PermitRootLogin prohibit-password
```

```sh
root@server ~ % systemctl restart ssh.service
```

  * Check in another terminal that you still have access to the server.

```sh
neze@laptop ~ % ssh root@example.com "echo OK"
OK
```

  * Check that you do not have password access anymore.

```sh
neze@laptop ~ % ssh -o PreferredAuthentications=password root@example.com
root@93.184.216.34 password:
Permission denied, please try again.
```

### Create your main user

  * Create your user.

```sh
root@server ~ % adduser neze
```

  * Put the user in the sudo group.

```sh
root@server ~ % usermod -aG sudo neze
root@server ~ % groups neze
neze: neze sudo
```

  * Copy your ssh public key to this user on the server.

```sh
neze@laptop ~ % ssh-copy-id -i ~/.ssh/id_example.com.pub neze@example.com
neze@93.184.216.34 password:
```

  * Check that you have access to your user's shell.

```sh
neze@laptop ~ % ssh neze@example.com "echo OK"
OK
```

  * Disable root login

```sh
root@server ~ % vi /etc/ssh/sshd_config
```

```diff
-PermitRootLogin prohibit-password
+PermitRootLogin no
```

```sh
root@server ~ % systemctl restart ssh.service
```

  * Check that you still have access to your user's shell.

```sh
neze@laptop ~ % ssh neze@example.com "echo OK"
OK
```

  * Maybe completely disable password authentication.

```sh
neze@laptop ~ % ssh neze@example.com
neze@server ~ % sudo vi /etc/ssh/sshd_config
```

```diff
-PasswordAuthentication yes
+PasswordAuthentication no
```

```sh
neze@server ~ % sudo systemctl restart ssh.service
```

## Setup a basic firewall

### Block everything but SSH

*Be careful with this section.*

**Good to know:** If you do a mistake during firewall setup, a server reboot
will clean the filters and you will be able to restart the firewall part.

A commented version of the iptables rules is available [here][fw-gist].

```sh
# The three first lines:
## Create a temporary directory in /tmp
## Make sure you own the directory and nobody can write/read in it
## Empty the directory
root@server ~ % D=$(mktemp -d)
root@server ~ % chown -R root:root $D && chmod -R 700 $D
root@server ~ % find $D -mindepth 1 -delete
root@server ~ % cat << EOF > $D/iptables
*filter
:INPUT DROP
:FORWARD DROP
:OUTPUT ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
-A INPUT -m conntrack --ctstate INVALID -j REJECT --reject-with icmp-host-unreachable
-A INPUT -p icmp -j ACCEPT
-A INPUT -p tcp -m conntrack --ctstate NEW -m tcp --dport 22 -j ACCEPT
-A INPUT -m limit --limit 30/min -j LOG --log-prefix "iptables INPUT denied: " --log-level 7
-A FORWARD -m limit --limit 30/min -j LOG --log-prefix "iptables FORWARD denied: " --log-level 7
COMMIT
EOF
root@server ~ % iptables-apply $D/iptables
```

Check that you can still connect to your server and that the output of the
command `iptables-save` does look like what you typed up there.

Do not close this terminal <i class="fa fa-heart"></i>

### Make these iptables permanent

You are going to save these iptables, and use a script to automatically apply
them whenever network interfaces are set up.

```sh
root@server ~ % mkdir firewall
root@server ~ % cp $D/iptables firewall/iptables.rules
root@server ~ % curl -Ls 'https://gist.githubusercontent.com/w2ak/88cf0aad6cb58cfc0c5083c467eb4619/raw/2da598837dfa122e8b79b1326b4242b1d88b87af/restore.sh' > firewall/restore.sh
# It is advised to read and eventually edit restore.sh before making it executable
root@server ~ % chmod 700 firewall/restore.sh
root@server ~ % ln -s $(pwd)/firewall/restore.sh /etc/network/if-pre-up.d/iptables
```

The script will be downloaded with 'curl'. It is actually the `restore.sh` script
from [this page][fw-gist], which you can also manually download and put on your
server. If you do so, it will look like this.

```sh
# First download 'restore.sh' and know where it is in your laptop
neze@laptop ~ % scp Downloads/restore.sh neze@example.com:.
neze@laptop ~ % ssh neze@example.com
...
neze@server ~ % sudo -s
root@server ~neze % cd && mkdir firewall
root@server ~ % mv ~neze/restore.sh firewall/.
root@server ~ % chown root:root firewall/restore.sh
root@server ~ % chmod 700 firewall/restore.sh
root@server ~ % ln -s $(pwd)/firewall/restore.sh /etc/network/if-pre-up.d/iptables
```

[fw-gist]: https://gist.github.com/w2ak/88cf0aad6cb58cfc0c5083c467eb4619
