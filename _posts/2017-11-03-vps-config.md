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

# Web server setup

## Install a LAMP server

Get the following software to have a basic LAMP server. If you only want simple
static pages you can avoid downloading the `php` and `mysql` related software.

```
root@server ~ % apt-get install acl apache2 php mysql-server libapache2-mod-php php-mysql
```

## Setup a basic static website

### Create your tree

**Careful**: try to respect the user that is executing the commands in the following
example. At first you need to be root, but try to avoid being root when the example
doesn't use it.

Create the directory in which you will put your website, then set the correct
permissions.

```sh
# Create the directories
root@server ~ % mkdir -p /var/www/example.com/html /var/www/example.com/logs
# Allow minimum access to /var/www
root@server ~ % chmod 751 /var /var/www
# Allow only root access to /var/www/example.com
root@server ~ % chmod -R u=rwX,g=rX,o-rwx /var/www/example.com
# Add sticky bit (protects ownership) to /var/www/example.com/html
root@server ~ % chmod +s /var/www/example.com/html
# Allow reading access for www-data (the web server user) to /var/www/example.com/html
root@server ~ % setfacl -Rm d:u:www-data:r-X,u:www-data:r-X /var/www/example.com/html
# Allow writing access for my user
root@server ~ % setfacl -Rm d:u:neze:rwX,u:neze:rwX /var/www/example.com/html
```

Create **as your user** (not root) the first html page. *Do not create `index.html`
yet, it will allow you to perform a basic check.*

```sh
neze@server ~ % vim /var/www/example.com/html/first.html
```

```diff
+<html>
+  <head>
+    <title>My first page</title>
+  </head>
+  <body>
+    <h1>Super beautiful title</h1>
+    <p>For a super beautiful website.</p>
+  </body>
+</html>
```

Check that the file you just created is owned by the `root` group.

```sh
neze@server ~ % ls -lah /var/www/example.com/html
total 12K
drwsrws---+ 2 root root 4,0K Dec  1 10:04 .
drwxrwx---+ 4 root root 4,0K Dec  1 09:50 ..
-rw-rw----+ 1 neze root    0 Dec  1 10:04 first.html
```

### Configure the web server to deliver the website

Create a basic configuration file for this website.

```sh
root@server ~ % vim /etc/apache2/sites-available/example.com.conf
```

```diff
+<VirtualHost *:80>
+  ServerAdmin neze@example.com
+  ServerName example.com
+  DocumentRoot /var/www/example.com/html
+
+  ErrorLog /var/www/example.com/logs/error.log
+  CustomLog /var/www/example.com/logs/access.log combined
+
+  <Directory /var/www/example.com/html>
+    Options -Indexes -FollowSymLinks
+    DirectoryIndex index.html index.php
+    AllowOverride None
+    Order allow,deny
+    Allow from all
+    Require all granted
+  </Directory>
+</VirtualHost>
```

Disable every website enabled by apache, then enable your own.

```sh
root@server ~ % ls /etc/apache2/sites-enabled
000-default
root@server ~ % a2dissite 000-default
root@server ~ % a2ensite example.com
root@server ~ % systemctl restart apache2.service
```

Check that you have access to the website **from your server**.

```sh
# This should give "403 forbidden" you don't have permission.
neze@server ~ % curl -Ls localhost
# This should show you the web page you created.
neze@server ~ % curl -Ls localhost/first.html
```

Open the `http` and `https` ports in the firewall.

```sh
root@server ~ % vim ~/firewall/iptables.rules
```

```diff
 -A INPUT -p icmp -j ACCEPT
 -A INPUT -p tcp -m conntrack --ctstate NEW -m tcp --dport 22 -j ACCEPT
+-A INPUT -p tcp -m conntrack --ctstate NEW -m tcp --dport 80 -j ACCEPT
+-A INPUT -p tcp -m conntrack --ctstate NEW -m tcp --dport 443 -j ACCEPT
 -A INPUT -m limit --limit 30/min -j LOG --log-prefix "iptables INPUT denied: " --log-level 7
 -A FORWARD -m limit --limit 30/min -j LOG --log-prefix "iptables FORWARD denied: " --log-level 7
```

```sh
root@server ~ % iptables-apply ~/firewall/iptables.rules
```

Check in your web browser on your computer that you *do not* have access to
`http://example.com/` and that you do have access to `http://example.com/first.html`.

## Add https support

### Obtain ssl certificates

Install certbot to use [letsencrypt](https://letsencrypt.org) certificates. They
are free SSL certificates that will allow you to have secure https websites
access without having to pay an expensive Certificate Authority.
Then, enable apache ssl support.

```sh
root@server ~ % apt-get install certbot
root@server ~ % a2enmod ssl
```

Ask Let's Encrypt for a certificate for your web server. The `certbot` utility
will ask you for a valid e-mail (at least the first time).

```sh
root@server ~ % certbot --webroot --webroot-path /var/www/example.com/html -d example.com certonly
```

In the end, links to certificates should be available in the `letsencrypt` folder.
It is important to use the `live` folder (see below) because this folder will
always be valid, even when the certificates will be renewed (we'll talk about
renewal down there).

```sh
root@server ~ % ls /etc/letsencrypt/live/example.com
total 4
lrwxrwxrwx 1 root root  31 Nov 23 12:37 cert.pem -> ../../archive/example.com/cert1.pem
lrwxrwxrwx 1 root root  32 Nov 23 12:37 chain.pem -> ../../archive/example.com/chain1.pem
lrwxrwxrwx 1 root root  36 Nov 23 12:37 fullchain.pem -> ../../archive/example.com/fullchain1.pem
lrwxrwxrwx 1 root root  34 Nov 23 12:37 privkey.pem -> ../../archive/example.com/privkey1.pem
-rw-r--r-- 1 root root 543 Sep 24 13:06 README
```

### Setup ssl in the website

Modify the configuration of your website for it to be available only with https.

```sh
root@server ~ % vim /etc/apache2/sites-available/example.com.conf
```

```diff
 <VirtualHost *:80>
+  ServerAdmin neze@example.com
+  ServerName example.com
+  Redirect permanent / https://example.com/
+</VirtualHost>
+<VirtualHost *:443>
+  SSLEngine on
+  SSLCertificateFile /etc/letsencrypt/live/example.com/cert.pem
+  SSLCertificateKeyFile /etc/letsencrypt/live/example.com/privkey.pem
+  SSLCertificateChainFile /etc/letsencrypt/live/example.com/chain.pem
+
   ServerAdmin neze@example.com
   ServerName example.com
   DocumentRoot /var/www/example.com/html
 
   ErrorLog /var/www/example.com/logs/error.log
   CustomLog /var/www/example.com/logs/access.log combined
 
   <Directory /var/www/example.com/html>
     Options -Indexes -FollowSymLinks
     DirectoryIndex index.html index.php
     AllowOverride None
     Order allow,deny
     Allow from all
     Require all granted
   </Directory>
 </VirtualHost>
```

Reload the `apache2` server.

```sh
root@server ~ % systemctl reload apache2.service
```

Check in your web browser (in this order) that you have access to
`https://example.com/first.html` and that `http://example.com/firts.html` is
redirected to the https version.

### Setup automatic ssl certificates renewal

The SSL certificates you obtained are valid for 60 days. This is the default
and mandatory value with Let's Encrypt certificates. You need to setup automatic
renewal for these certificates.

First, try manual certificate to understand what it does.

```sh
root@server ~ % which certbot
/usr/bin/certbot
root@server ~ % /usr/bin/certbot renew
Saving debug log to /var/log/letsencrypt/letsencrypt.log

-------------------------------------------------------------------------------
Processing /etc/letsencrypt/renewal/example.com.conf
-------------------------------------------------------------------------------
Cert not yet due for renewal

The following certs are not due for renewal yet:
  /etc/letsencrypt/live/example.com/fullchain.pem (skipped)
No renewals were attempted.
```

You can see that renewal will only be performed when needed. You can then simply
setup a regular execution of this command (once every week for example).

Choose randomly a minute (here, **33**), an hour (here, **4**) and a day of the
week (here, **1**). Then, setup automatic renewal of your certificates.

```sh
root@server ~ % crontab -e
```

```diff
 # m h  dom mon dow   command
+33 4 * * 1 /usr/bin/certbot renew
```

[fw-gist]: https://gist.github.com/w2ak/88cf0aad6cb58cfc0c5083c467eb4619
