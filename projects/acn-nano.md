---
layout: post
title: Kubernetes over Rancher with Ansible
toc: false
asciinema: true
author: Clément Durand & Carolina de Senne Garcia
date: 2018-02-09
permalink: /projects/ansible-rancher-kubernetes/

---

# Overview of the environment

![Server Overview](https://www.neze.fr/public/acn/nano/server-overview.svg)

![Global Overview](https://www.neze.fr/public/acn/nano/global-overview.svg)

# A simple use case

# Demo

## Step 1 - Start from a clean server

**Install Ubuntu on the server.** We first prepare a simple server with Ubuntu
and a public IP address. For security purposes it is better to setup SSH access
with a key that will also be used by Ansible to access and configure the server.

![OS Install](https://www.neze.fr/public/acn/nano/server-os-install.png)

Post-install, the server is clean and only the minimal system is setup. For
instance, there is no web server listening on the public IP address.

![HTTP Refused](https://www.neze.fr/public/acn/nano/server-os-install-after.png)

## Step 2 - Install and configure the server

**Run the first part of the Ansible install.** We use the `install` script in
our server administration repository. It basically calls `ansible` and gives
it the *hosts inventory* (configuration to access the managed servers) along
with the *playbook* (list of tasks to realize).

<div style="text-align:center">
  <script src="https://asciinema.org/a/161756.js" id="asciicast-161756" async></script>
</div>

During this first part of the installation, ansible realizes a basic setup of
the server to provide a healthy environment. It configures users accounts, a
safe SSH access, installs programs, configures docker and the nginx web server.

![Nginx Index](https://www.neze.fr/public/acn/nano/server-install-nginx.png)

When the installation is over, a nginx proxy was configured and the default
webpage was overriden. The nginx proxy will be used to reach the Rancher Web
Interface.

![Perdu](https://www.neze.fr/public/acn/nano/server-install-after.png)

## Step 3 - Install, launch and configure Rancher

Before installing Rancher, trying to reach its Web Interface is a failure. The
nginx proxy is indeed configured but there is nothing yet behind.

![Bad Gateway](https://www.neze.fr/public/acn/nano/rancher-install-before.png)

The Rancher setup part is probably the most complicated of all. Ansible has to
install Rancher, then use its API to configure it as wished. A few steps of this
installation are detailed afterwards.

<div style="text-align:center">
  <script src="https://asciinema.org/a/161759.js" id="asciicast-161759" async></script>
</div>

The Rancher interface is publicly accessible so the first setup step configures
authentication in Rancher. Once Rancher is launched and has authentication, the
login page is accessible.

![Authentication](https://www.neze.fr/public/acn/nano/rancher-install-after.png)

Next step is about setting up and activating a Kubernetes environment, i.e., a
container platform in rancher that will be managed by Kubernetes. Once the
environment is setup in Rancher, we can see that Rancher is actually starting
every required element of Kubernetes.

![Kubernetes](https://www.neze.fr/public/acn/nano/kubernetes-install.png)

Once Kubernetes was started by Rancher, its web interface can also be accessed
and it shows the running backbone services that are necessary to have a working
instance of Kubernetes.

![Kubernetes UI](https://www.neze.fr/public/acn/nano/kubernetes-install-after.png)

With only this setup, we only have the controler part of Kubernetes. We register
a host that will be usable by Kubernetes as ressources. In our single-host use
case, the registered host is the same as the controller host.

![Kubernetes Host](https://www.neze.fr/public/acn/nano/kubernetes-install-host.png)

![Kubernetes Host Up](https://www.neze.fr/public/acn/nano/kubernetes-install-host-after.png)

## Step 4 - Configure kubectl to control Kubernetes

KubeControl (`kubectl`) can be used from anywhere to control kubernetes by
connecting to the API of our machine. We install and configure it on the same
machine to be able to use `kubectl` commands on the host and manage the
Kubernetes instance.

Ansible obtains an administration token from the Rancher API, then pushes a
valid `kubectl` configuration on the host.

<div style="text-align:center">
  <script src="https://asciinema.org/a/161747.js" id="asciicast-161747" async></script>
</div>

## Step 5 - Run a simple web service with load balancing

Ansible first checks if the web service we want is already running and accessible.
Then, it can run the service, make it accessible (expose it) or scale it if
the number of replicas is different in the configuration.

<div style="text-align:center">
  <script src="https://asciinema.org/a/161750.js" id="asciicast-161750" async></script>
</div>

In the User Interface of Kubernetes we can see the two replicas of the web
service that was started by Ansible.

![KubeUI](https://www.neze.fr/public/acn/nano/kubernetes-helloacn-after.png)

![Kube Service](https://www.neze.fr/public/acn/nano/kubernetes-helloacn-service-65qsk.png)

![Kube Service](https://www.neze.fr/public/acn/nano/kubernetes-helloacn-service-ng4m4.png)

## Step 6 - Try some scaling

Now if in the configuration we change the desired number of replicas, Ansible
indeed scales the service and uses `kubectl` to have Kubernetes update the
desired scale.

<div style="text-align:center">
  <script src="https://asciinema.org/a/161751.js" id="asciicast-161751" async></script>
</div>

The User Interface shows more replicas, and when you access the web service you
can see three new distinct instances.

![Kube UI](https://www.neze.fr/public/acn/nano/kubernetes-helloacn-scaling-after.png)

![Kube Service](https://www.neze.fr/public/acn/nano/kubernetes-helloacn-service-pjmqn.png)

![Kube Service](https://www.neze.fr/public/acn/nano/kubernetes-helloacn-service-rssdv.png)

![Kube Service](https://www.neze.fr/public/acn/nano/kubernetes-helloacn-service-wflhd.png)
