---
layout: post
title: VPS First Configuration
category:
 - computer-science
 - notes
toc: large
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
# Allow others to go through /var/www/example.com
root@server ~ % chmod o+x /var/www/example.com
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

First, try manual certificate renewal to understand what it does.

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

# VPN setup

**WARNING**: This section is a work in progress.

Setup a VPN server with OpenVPN

## The concept

A Virtual Private Network is made to group devices (your server, a phone,
a laptop) as if they were in the same network. In this context, your server
will act as the VPN server, i.e., as the gateway or the main router of the
network. When connected to the VPN, the devices should be able to access the
other devices or the network including the server, and might if you enable it
access the Internet through (acting as) your server.

This possibility to act as your server and access other devices makes security
very important for the access to the VPN. For this purpose, authentication will
be realized by using a system of SSL certificates and asymetric ciphering.

More precisely, you will create a certificate authority that I will call **ca**
and should be located on a safe machine if you want to be serious. The certificate
authority will issue certificates for every actor of the VPN, including the
server. In order to access the server, a client will need to own a valid
certificate and its corresponding private key.

Here, the ciphering algorithms will use 2kiB RSA keys. Elliptic curves are not
used because the current version of the OpenVPN client for iOS does not implement
ECDSA support.

## Prepare mentally

You need to prepare a few things in order to make sure that the architecture is
clear in your head. This will avoid mistakes and help you go through the setup
without too much unnecessary pain.

### Network architecture

You will configure a server, still called **server** because it is the same
physical machine as your vps, and a client. Here it will be **laptop**.

The openvpn server is located on your online machine (*example.com*) and will
listen on a specific port (here, **993**) in udp or tcp (here, **tcp**).

The private network will have a [private address space][privipv4]. In this
tutorial we will use **10.0.0.0/24**, i.e., addresses from 10.0.0.0 to
10.0.0.255. The [network mask][mask] will then be **255.255.255.0**. Do not
hesitate to visit the links if there is something you do not understand.

**Actors naming**: I usually name the actors with subdomains of the server's
domain. It allowed me for example to easily add them to my internal DNS zone.
Here, the server will then be **vpn.example.com**, and the client will be
named **laptop.example.com**.

### Certificates and keys management

We will use [easy-rsa][easyrsadl] to manage keys and certificates. One easy-rsa
instance is used as follows (details will be given later, no need to try now):
* You download and extract the archive available under the easy-rsa link
* You extract it in a folder that will be the easy-rsa instance
* You apply [this patch][easyrsapatch] to fix a minor bug
* In this folder there is an executable `easyrsa` that allows to perform almost
every operation.
* There will be a `pki` folder containing important files
  * ciphering parameters
  * private keys
  * certificates
  * certificate requests

A good practice is to compartimentalize, i.e., have a seperate easy-rsa instance
for every actor in the vpn:
* One instance for the certificate authority on the machine **ca** (possibly your
laptop, preferably not your server)
* One instance for the server on the machine **server**
* One instance for the client on the machine **laptop**

You can still, if you want, have only one instance for every actor. This means
that the **ca** instance will generate everything, including the keys of everybody.
The tutorial assumes you are using separate instances.

## Create and manage certificates

### Prepare a blank instance

You need to fix a minor bug in easy-rsa and do a little personalization. In this
section, you will create your own easy-rsa archive and use it to create every
instance.

* Download the [easy-rsa archive][easyrsadl]
* Download the [easy-rsa patch][easyrsapatch]
* Apply the bug-fixing patch to your easy-rsa folder as follows

```sh
neze@laptop ~ % ls ~/Downloads && cd ~/Downloads
EasyRSA-3.0.3.tgz  easyrsa-bash-bug.patch
neze@laptop Downloads % tar xzf EasyRSA-3.0.3.tgz
neze@laptop Downloads % cd EasyRSA-3.0.3
neze@laptop EasyRSA-3.0.3 % git apply ../easyrsa-bash-bug.patch
```

<span class="lettrine"><i class="fa fa-exclamation-triangle"></i></span>
If you have an error while applying the patch, it means that you probably
copy-pasted the patch instead of saving it. Open the link in your browser then
`File>Save` it as `easyrsa-bash-bug.patch` for example.

* Create your own settings file

```sh
neze@laptop EasyRSA-3.0.3 % cp vars.example vars
neze@laptop EasyRSA-3.0.3 % vim vars
```

```diff
-#set_var EASYRSA_REQ_COUNTRY   "US"
-#set_var EASYRSA_REQ_PROVINCE  "California"
-#set_var EASYRSA_REQ_CITY      "San Francisco"
-#set_var EASYRSA_REQ_ORG       "Copyleft Certificate Co"
-#set_var EASYRSA_REQ_EMAIL     "me@example.net"
-#set_var EASYRSA_REQ_OU        "My Organizational Unit"
+set_var EASYRSA_REQ_COUNTRY   "FR"
+set_var EASYRSA_REQ_PROVINCE  "."
+set_var EASYRSA_REQ_CITY      "Paris"
+set_var EASYRSA_REQ_ORG       "MyCAOrg"
+set_var EASYRSA_REQ_EMAIL     "whatever@example.com"
+set_var EASYRSA_REQ_OU        "MyVPNOrg"
```

* Pack your own archive. You will use it for every easy-rsa instance

```sh
neze@laptop Downloads % ls
EasyRSA-3.0.3.tgz EasyRSA-3.0.3  easyrsa-bash-bug.patch
neze@laptop Downloads % mv EasyRSA-3.0.3 custom-easyrsa
neze@laptop Downloads % tar czf custom-easyrsa.tgz custom-easyrsa
```

### Initialize the CA instance

Download and extract your custom easy-rsa wherever you want
(preferably in a safe place) on the **ca** machine.

Initialize a `pki` then a certificate authority. The certificate authority will
own everything that is shared between the actors of the VPN. The passphrase
should be considered important.

```sh
neze@ca easy-rsa % ./easyrsa init-pki
neze@ca easy-rsa % ./easyrsa build-ca
# ...
Enter PEM pass phrase: *********************************************
Verifying - Enter PEM pass phrase: *********************************************
Common Name (eg: your user, host, or server name) [Easy-RSA CA]:example.com
# ...
neze@ca easy-rsa % ssh server "openvpn --genkey --secret /dev/fd/1" > pki/private/tls.key
```

### Initialize the server instance

Download and extract your custom easy-rsa. Then, initialize a `pki` and create
a request for your server.

A useful practice is to avoid putting a password to the server key, in order to be
able to automatically start the VPN server.

```sh
root@server easy-rsa % ./easyrsa init-pki
root@server easy-rsa % ./easyrsa gen-req vpn.example.com nopass
# ...
Common Name (eg: your user, host, or server name) [vpn.example.com]:
# ...
root@server easy-rsa % ./easyrsa gen-dh
# This process can be long and allows VPN connections to be faster
```

This process put a **private** key in `pki/private/vpn.example.com.key`, and
a certificate request in `pki/reqs/vpn.example.com.req`. You also created
**secret** Diffie-Hellman parameters in `pki/dh.pem`.

### Initialize the client instance

This time you can (and maybe should) put a password. If you are creating an iOS
client, though, I was not able to use password-protected keys yet.

```sh
neze@laptop easy-rsa % ./easyrsa init-pki
neze@laptop easy-rsa % ./easyrsa gen-req laptop.example.com # nopass
```

### Issue certificates for the client and the server

With the CA instance, you now need to sign the requests from the server and the
client. Make the two requests files you generated available to the **ca**
machine.

**You do not need to send anything else to the CA machine.** Only send the `.req`
files (for example by e-mail) using any non necessarily secure channel.

Then, simply sign the requests with the CA instance.

```sh
neze@ca ~ % ls /path/to/requests
laptop.example.com.req  vpn.example.com.req

neze@ca easy-rsa % ./easyrsa import-req /path/to/requests/vpn.example.com vpn.example.com
neze@ca easy-rsa % ./easyrsa import-req /path/to/requests/laptop.example.com laptop.example.com

neze@ca easy-rsa % ./easyrsa sign-req server vpn.example.com
# ...
  Confirm request details: yes
# ...
Enter pass phrase for pki/private/ca.key: *********************************************
# ...
neze@ca easy-rsa % ./easyrsa sign-req client laptop.example.com
```

This generated two `.crt` files in the `pki/issued` folder. Send the following
files to each actor:
* The `pki/ca.crt` file is the certificate of the authority.
* The `pki/private/tls.key` file is the pre-shared key file for additional security.
* The `pki/issued/__name__.example.com.crt` is the certificate file for the
corresponding actor.

It is better to use a secure channel this time because the `tls.key` file is
supposed to remain at least a minimum private.

Down there is an example to make it private. The client will need `openssl` to
decipher it.

* On the CA: prepare a secure archive to send to (for example) **vpn**.

```sh
neze@ca easy-rsa % mkdir -p build && chmod 700 build
neze@ca easy-rss % cp pki/ca.crt pki/private/tls.key pki/issued/vpn.example.com.crt pki/reqs/vpn.example.com.req build/.
neze@ca easy-rsa % cd build
neze@ca build % openssl req -in vpn.example.com.req -noout -pubkey -out vpn.example.com.pub
neze@ca build % openssl rand 192 -out vpn.example.com.tgz.key
neze@ca build % tar cf - ca.crt tls.key vpn.example.com.crt | openssl aes-256-cbc -pass file:vpn.example.com.tgz.key -out vpn.example.com.tgz.enc
neze@ca build % openssl rsautil -encrypt -pubin -inkey vpn.example.com.pub -in vpn.example.com.key -out vpn.example.com.tgz.key.enc
```

* Send the `*.enc` files (two files) to the client.
* On the client: decrypt the data and get the files

```sh
neze@server tmp-folder % openssl rsautl -decrypt -ssl -inkey /path/to/easyrsa/pki/private/vpn.example.com.key -in vpn.example.com.tgz.key.enc -out vpn.example.com.tgz.key
neze@server tmp-folder % openssl aes-256-cbc -d -pass file:vpn.example.com.tgz.key -in vpn.example.com.tgz.enc | tar xf -
```

* Now you have access to `tls.key`, `ca.crt`, `vpn.example.com.crt`.

## OpenVPN server

In the server we will create a `vpn` folder (here it will be `/root/vpn`) that
will eventually contain every necessary file for the OpenVPN server to run.

```sh
root@server ~ % mkdir /root/vpn && cd /root/vpn
root@server vpn % cp /path/to/ca.crt /path/to/tls.key /path/to/vpn.example.com.crt /path/to/vpn.example.com.key /path/to/dh.pem .
root@server vpn % chmod 400 tls.key vpn.example.com.key dh.pem
root@server vpn % chmod 444 ca.crt vpn.example.com.crt
```

Once you are sure that you got the `.key` file and `dh.pem` file, you can delete
the easy-rsa server instance if you want and if it is only the server's instance.

### Server config file

We will create a basic configuration. You should use absolute paths in this
configuration because it could be used from any working directory. Remember
that the default values mentioned before and used in the configuration file
should be changed depending on what you chose.

```sh
root@server vpn % touch server.conf && chmod 644 server.conf
root@server vpn % vim server.conf
```

```diff
+port                    993
+proto                   tcp
+dev                     tun
+topology                subnet
+server                  10.0.0.0 255.255.255.0
+ifconfig-pool-persist   /root/vpn/ipp.txt
+push                    "route 10.0.0.0 255.255.255.0"
+client-to-client
+keepalive               10 120
+cipher                  AES-256-CBC
+max-clients             5
+user                    nobody
+group                   nogroup
+persist-key
+persist-tun
+log                     /root/vpn/server.log
+verb                    3
+
+dh                      /root/vpn/dh.pem
+
+tls-auth                /root/vpn/tls.key 0
+ca                      /root/vpn/ca.crt
+cert                    /root/vpn/vpn.example.com.crt
+key                     /root/vpn/vpn.example.com.key
```

If you intend to use udp, you should slightly change the setup as follows

```diff
 port                    993
-proto                   tcp
+proto                   udp
+explicit-exit-notify
 dev                     tun
```

You can quickly test that there is nothing wrong with this configuration by
commenting out the logfile instruction and running openvpn.

```sh
root@server vpn % openvpn --config server.conf
```

### Client config files

Then, you need to write sample configurations for the clients because their
configuration needs to match the server's.

```sh
root@server vpn % touch client.conf && chmod 644 client.conf
root@server vpn % vim client.conf
```

```diff
+client
+proto           tcp
+remote          example.com 993
+dev tun
+resolv-retry    infinite
+nobind
+persist-key
+persist-tun
+remote-cert-tls server
+cipher          AES-256-CBC
+ping            10
+ping-restart    30
+
+tls-auth        tls.key 1
+ca              ca.crt
+cert            client.crt
+key             client.key
```

You should also create a sample self-contained configuration. Its use will be
explained in the client part.

```sh
root@server vpn % cp client.conf client.ovpn
root@server vpn % vim client.ovpn
```

```diff
 ping-restart    30
 
-tls-auth        tls.key 1
+key-direction   1
+<tls-auth>
+-----BEGIN OpenVPN Static key V1-----
+...
+-----END OpenVPN Static key V1-----
+</tls-auth>
-ca              ca.crt
+<ca>
+-----BEGIN CERTIFICATE-----
+...
+-----END CERTIFICATE-----
+</ca>
-cert            client.crt
+<cert>
+-----BEGIN CERTIFICATE-----
+...
+-----END CERTIFICATE-----
+</cert>
-key             client.key
+<key>
+-----BEGIN PRIVATE KEY-----
+...
+-----END PRIVATE KEY-----
+</key>
```

### Enable your OpenVPN instance

There are two independant steps in this process: setup and start the openvpn
service, and open the necessary parts of the firewall.

We will start with the openvpn service. Create a link to your configuration in
the openvpn folder.

```sh
root@server ~ % ln -s /root/vpn/server.conf /etc/openvpn/vpn.example.com.conf
```

Modify the openvpn configuration to automatically start your vpn server.

```sh
root@server ~ % vim /etc/default/openvpn
```

```diff
-#AUTOSTART="all"
+AUTOSTART="all"
```

```sh
root@server ~ % systemctl daemon-reload
```

Enable and start the openvpn service, then check that your OpenVPN server is
running.

```sh
root@server ~ % systemctl enable openvpn.service
root@server ~ % systemctl start openvpn@vpn.example.com.service
root@server ~ % ps aux | grep openvpn
```

You also need to configure the firewall. You should open the correct port to
enable clients to access your OpenVPN server.

```sh
root@server ~ % vim ~/firewall/iptables.rules
```

```diff
 -A INPUT -p tcp -m conntrack --ctstate NEW -m tcp --dport 22 -j ACCEPT
 -A INPUT -p tcp -m conntrack --ctstate NEW -m tcp --dport 80 -j ACCEPT
 -A INPUT -p tcp -m conntrack --ctstate NEW -m tcp --dport 443 -j ACCEPT
+-A INPUT -p tcp -m conntrack --ctstate NEW -m tcp --dport 993 -j ACCEPT
 -A INPUT -m limit --limit 30/min -j LOG --log-prefix "iptables INPUT denied: " --log-level 7
+-A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
 -A FORWARD -m limit --limit 30/min -j LOG --log-prefix "iptables FORWARD denied: " --log-level 7
 COMMIT
```

```sh
root@server ~ % iptables-apply ~/firewall/iptables.rules
```

Then, enable forwarding and set it persistent.

```sh
root@server ~ % sysctl -w net.ipv4.conf.all.forwarding=1
root@server ~ % vim ~/firewall/restore.sh
```

```diff
 # enabling forwarding is necessary if you have a VPN
-# sysctl -w net.ipv4.conf.all.forwarding=1 >/dev/null 2>/dev/null
+sysctl -w net.ipv4.conf.all.forwarding=1 >/dev/null 2>/dev/null
 # do not forget ipv6 firewall if your server is ipv6 enabled
```

### Additional firewall configuration

The firewall configuration you did only enabled connections between your VPN
clients and your server. Right now, a VPN client can connect to the VPN server
and has the same rights as any other machine trying to access your server.

Identify the `tun` interface your openvpn server is working on. Here, it will
be **tun0**. Identify the interface connected to Internet. Here, it will be
**eth0**.

```sh
root@server ~ % ip link
```

#### Internet access

Enable VPN clients to access Internet through (as) your VPN server.

```sh
root@server ~ % vim ~/firewall/iptables.rules
```

```diff
 -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
+-A FORWARD -i tun0 -s 10.0.0.0/24 -o eth0 -j ACCEPT
 -A FORWARD -m limit --limit 30/min -j LOG --log-prefix "iptables FORWARD denied: " --log-level 7
 COMMIT
+*nat
+:PREROUTING ACCEPT
+:INPUT ACCEPT
+:OUTPUT ACCEPT
+:POSTROUTING ACCEPT
+-A POSTROUTING -s 10.0.0.0/24 -o eth0 -j SNAT --to-source 93.184.216.34
+COMMIT
```

```sh
root@server ~ % iptables-apply ~/firewall/iptables.rules
```

#### Client-to-client access

Enable VPN clients to access each other.

```sh
root@server ~ % vim ~/firewall/iptables.rules
```

```diff
 -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
 -A FORWARD -i tun0 -s 10.0.0.0/24 -o eth0 -j ACCEPT
+-A FORWARD -i tun0 -s 10.0.0.0/24 -o tun0 -d 10.0.0.0/24 -j ACCEPT
 -A FORWARD -m limit --limit 30/min -j LOG --log-prefix "iptables FORWARD denied: " --log-level 7
 COMMIT
 *nat
```

```sh
root@server ~ % iptables-apply ~/firewall/iptables.rules
```

## OpenVPN client

Depending on your OS, you will use different softwares. On some software, it is
easier to use standalone config files (here they are `*.ovpn` files to make it
simpler).

* MacOS: install Tunnelblick
* Linux: you can use openvpn with NetworkManager
* iOS and Android: OpenVPN Connect

This part gives simple explanations about the whole process because with so much
information above, it is difficult to have a clear idea of what you need to do.

### What you need

* A laptop with openssl installed and a working folder that I will call `build`.
* A client (possibly the same laptop, unless your client is a phone).
* An already configured server.

### Steps to add this client

* Provide the client laptop with your custom easy-rsa (this way the configuration is
the same).
* On the client laptop
  * [Create the request](#initialize-the-client-instance)
  * Send the request to the CA
  * Put the private key from `pki/private/_client_.key` to your `build` folder
  * You can delete the client easy-rsa instance
* On the CA
  * [Sign the client request](#issue-certificates-for-the-client-and-the-server)
  * Maybe encrypt the files before sending them. P.S. If you are using ssh for
  file transfers, no need to add the encryption layer
  * Send the files to the client laptop
* On the server
  * Send the two client config files to the client laptop
* On the client laptop
  * Maybe decrypt the files from the CA
  * Put every file in the `build` folder. You should have:
    * `client.conf` and `client.ovpn`
    * `ca.crt` and `tls.key`
    * `_client_.key` and `_client_.crt`
  * Use the config file of your choice (depending on whether you want a standalone
  config file or not) and modify it by taking data in the other files. Here are
  examples. The Base64 data was directly taken in the files.
  * Then you can just send the `client.ovpn` file, or an archive containing the
  `client.conf` file with the four keys and certificates files, to the client.
* On the client
  * Enjoy!

```diff
@ client.conf

-tls-auth        tls.key 1
-ca              ca.crt
-cert            client.crt
-key             client.key
+tls-auth        /path/to/tls.key 1
+ca              /path/to/ca.crt
+cert            /path/to/_client_.crt
+key             /path/to/_client_.key
```

```diff
@ client.ovpn

 ping-restart    30
 
 key-direction   1
 <tls-auth>
 -----BEGIN OpenVPN Static key V1-----
-...
+606aafbb7474cb29b5adb3436d7e5446
+4e33e66a57821dde9eb6843b1176d7dc
+75fcb94bd98dcd4234528ac2e318c504
+b51afc163b146b42b320bb9bce39f27c
+4bb1bd802e154aa58288256c6ac60a67
+1f3e0                      02b56
+8e75a                      994c8
+2c03a    Taken from the    1b29a
+ef79c    `tls.key' file    13226
+43a95                      b14fd
+aa25f                      be3ea
+82db6043752aef6a3de678ee3e128aa5
+b46838f307a13b0d1c7f729d34ba3197
+815a5670b434abde50c6958641480649
+8ff8de6929aa4ae021b8f7637957cf5d
+f4941e62b8502647aa00f050ea83f26c
 -----END OpenVPN Static key V1-----
 </tls-auth>
 <ca>
 -----BEGIN CERTIFICATE-----
-...
+MIIDNTCCAh2gAwIBAgIJAJs+aLUfaW2iMA0GCSqGSIb3DQEBCwUAMBYxFDASBgNV
+BAMMC2V4YW1wbGUuY29tMB4XDTE3MTIwODEzNDUyOFoXDTI3MTIwNjEzNDUyOFow
+FjEUMBIGA1UEAwwLZXhhbXBsZS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAw
+ggEKAoIBAQCib40mJ1L1R27v6pWVRpN1mk2fgZ0ijN8+GXbAcB71czjsWXxIZq2t
+f9nT/MQ+N1cbXCjjV/8eq25SjcHvHhoPns+QrTLryN/b8ujU7IAozW4IJ19cYnnv
+E735VxZtB/Ne9gLbf2C/74E3kZG8OpK1+RJ6idK4Gz4GQBCBytFqdQKT9s/sYyPA
+vsc+VEzXLOS09TyTzx1XGjjeamTm3mGlOHRIDxYa+r9SaLfLWv/TJhRAzgQNMyiC
+JWeRu                                                      yzIHE
+NoB/U           Taken from the `ca.crt' file.              EFBlm
+gBKuj                                                      C/yWH
+5k/roRqkGDAWMRQwEgYDVQQDDAtleGFtcGxlLmNvbYIJAJs+aLUfaW2iMAwGA1Ud
+EwQFMAMBAf8wCwYDVR0PBAQDAgEGMA0GCSqGSIb3DQEBCwUAA4IBAQB5+uEAoFhW
+FGQmP/sbB6fOHNfhK3sYmzOjkQGn3pdsyQ1MvwcL0qCyH+iWbmjxCWlWJRC0WkP3
+W0T9oOeKGuDCTLzjuyZ4M/d4IcFCdOliY517eVCaeE5/uYFEaBseJjDqfEPqDKhr
+XETj/hcZxXf6DcveyYE3dtJ7NEsTyfXaKCJTvgPOiIE0pZ2rjJMcO2d0+DNqpk3M
+lp8oMPiq9HxjdvFM45oupY3nbQEM70p0NkOxGnrMesC0Hl++H0pmpn4OJM1GNdEf
+mi9DRkWOfYbyWhmDivEbsAHxv+i9xsC5ia/NY5/uKWB9klDTfl0Sp+XdnDUduuFz
+HboGYhuJxNQJ
 -----END CERTIFICATE-----
 </ca>
 <cert>
 -----BEGIN CERTIFICATE-----
-...
+MIIDVTCCAj2gAwIBAgIQGLag/LPVbrqgd3eGx1drMDANBgkqhkiG9w0BAQsFADAW
+MRQwEgYDVQQDDAtleGFtcGxlLmNvbTAeFw0xNzEyMDgxMzU1MjhaFw0yNzEyMDYx
+MzU1MjhaMB0xGzAZBgNVBAMMEmxhcHRvcC5leGFtcGxlLmNvbTCCASIwDQYJKoZI
+hvcNAQEBBQADggEPADCCAQoCggEBALoBFuGdPD70L2vNGX2gE9EQ8gIwmCCF5Qll
+eJ4zShCpc77vnoPCFDYYUfR0re9nMceLnUBhDIGqq6EDWtHulnZuKuTF2VS9DoaR
+wbN/ttA9xfAsOgxycwk2pvKQtoi1vtYfZmBIuHu+8aBezUoHpcFZ8DZ7d6kPGNeY
+91SfJQHR9rMIMvHRz+3wBtyTiS2OqHWCTYEzpB7BsCejmZmgFduVcFh6HGx22Mv/
+jM4Gd                                                      uX3Yr
+kSNEq        Taken from the `_client_.crt' file.           BlzCB
+lDAJB                                                      GBgNV
+HSMEPzA9gBQZZoASro2Exk0prCyvAv8lh+ZP66EapBgwFjEUMBIGA1UEAwwLZXhh
+bXBsZS5jb22CCQCbPmi1H2ltojATBgNVHSUEDDAKBggrBgEFBQcDAjALBgNVHQ8E
+BAMCB4AwDQYJKoZIhvcNAQELBQADggEBABvBBoW17VJxXZmsV+PI1V5f9OWHcdrR
+ixIY4JoWGkzobn9Li+zlgvVPWjguL/VTXPX+J6aHcLW4w/hRsyDEYU9wNHjCNnFB
+CrYthURSVVC9ojUJ0KoUyTMomIQWCLpsv/Oa5rEcwYmjj9viLFN3FvyN7G6Z7jen
+DivtjNcf5cdy0k8uEYBarnf7OApP4XQSbE5Z+2YLyiGSMy5wxFCFeXH16/RcJp++
+PBE5ctCZqonO4wfGIs6PnnFK8kvyzeyr13bFVbZaMz0BmpOzNdMczl9SDyQw5FFf
+MvPE0YZQneJgJFXJKYu0NsyOsokyIXcUAsbzPenadKbP4X5OWdDQNt4=
 -----END CERTIFICATE-----
 </cert>
 <key>
 -----BEGIN PRIVATE KEY-----
-...
+MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC6ARbhnTw+9C9r
+zRl9oBPREPICMJggheUJZXieM0oQqXO+756DwhQ2GFH0dK3vZzHHi51AYQyBqquh
+A1rR7pZ2birkxdlUvQ6GkcGzf7bQPcXwLDoMcnMJNqbykLaItb7WH2ZgSLh7vvGg
+Xs1KB6XBWfA2e3epDxjXmPdUnyUB0fazCDLx0c/t8Abck4ktjqh1gk2BM6QewbAn
+o5mZoBXblXBYehxsdtjL/4zOBncCButs24pjRaAfQ4v0RKP/niFpQm+FPcE4lZb/
+EBkOwIF82UJxMJFhrl92K5EjRKk+Zm+WEatzfdI9xLc0VUz3T+LoNS7vsS1/1zPr
+6Rh7XrF9AgMBAAECggEAC8C33med/+hT+r7J5osv1Vz5vbOuWRe8whw8Q9q/yk+6
+tYzUekTQHB7rRsP8nYzqs04aEJBRRvwuvgzFN1CZB0CsyynJMraDbXNWRu5B8eSF
+VkilHlY4+JMQd3E3Z2n8dfEj+d9+cKs+/0AePpg/G/l/2SFyDSecDTtoHVu07eln
+pAU+W4WO0Dvx6hup5LOND3koBNTvYBeEk4GrB0W2Wr3lQV8X47zIOxVhFPfombDx
+6OuqOJPqZ0hfOa9vJJLNI0vzR79vSItJ95nFKE3yPawlUlGB8o42NQV+djtkJxxd
+2YLvZ                                                      iXF99
+4LPXC        Taken from the `_client_.key' file.           CNxoA
+3DMt8                                                      45/jv
+DuhmWd8y53yt/zIfaSCTIMa5ZQKBgQDBm4kAhqryw+BbIbSRzLwLxmK7qCrENHlC
+/Vp5qzo1PXw2AoNlQN4TbvQ3xWQZ4kdkJtUr0vDK6K4VR8o1GMm9fqNsdDTc2f1x
+q/a1s/iXVwDV6OFgyKcbPL5pAt+3vXVn79ZFknaxXEulWypOUdwosxhXXUXjZnwY
+KvE9OIAiOQKBgHH51UOGH23qyJio3Cv2jQETzghYgXwwDVK7k6/MIDzvIYvkdKxm
+IWJMxcZt72htU7rxgu2f0X+BL754UJmjcihRHXmFXn26vvv8OojEsn1DdJWfGae7
+np+p9QfqB00svpYbbA6L4j9glzNKdSc77mE4NuJdOn9b6zt5OXpVTyKtAoGAOk83
+sdrdPYRU292I3qiEsh8ruUzqpHERXGWljCNPwp0j/bhADoy81amDEBD5FvqZecZg
+SXScZOAzHeGjOt6eU94CJjXRffqBZGzgPtVXN21SqRocVuPXwFJJHqNo8ZOz+nu3
+UvjLmpsrhT+xvCjXX8KgwB8tX1GMalL0mPWdUbECgYEAmr6lsqd5UWlBzk3O/6Nf
+s90C9wKcDLyMjktu5fAk0pP/rZgfLcSc5pH1xIg/+ufktZqiOwDhm28Une4VDyuv
+q3po3yneF4CHVtNsg3J89xXTaCzyygCIRsqSmVwbGlDRSDftPytnB8vteMqrbPAk
+WOmXfzRj2ZsFLnldASN2jA8=
 -----END PRIVATE KEY-----
 </key>
```

[fw-gist]: https://gist.github.com/w2ak/88cf0aad6cb58cfc0c5083c467eb4619
[privipv4]: https://en.wikipedia.org/wiki/Private_network#Private_IPv4_address_spaces
[mask]: https://en.wikipedia.org/wiki/Subnetwork
[easyrsadl]: https://github.com/OpenVPN/easy-rsa/releases/latest
[easyrsapatch]: https://gist.githubusercontent.com/w2ak/54ae736732258400f42845d6f67f1b3a/raw/c9bb2026c597961fc610020db39d557752b7d32e/easyrsa-bash-bug.patch
