---
layout: post
title: Kubernetes over Rancher with Ansible
toc: false
asciinema: true
author: Clément Durand & Carolina de Senne Garcia
date: 2018-02-09
permalink: /projects/ansible-rancher-kubernetes/

---

At first, this project focuses on trying out [Kubernetes][kubernetes]. This is a container
management distribution that allows you to setup cloud services in containers
on multiple machines, to manage availability, redundancy, load balancing, etc.

Kubernetes is a professional solution sometimes difficult to install and maintain.
In many cases, companies just pay cloud providers to do this kind of work. [Rancher][rancher]
however gives an out-of-the-box solution to use several different container
managements distributions, among which is Kubernetes.

We tried to install experimental services on Kubernetes, which had the whole
stack crash a lot of times. To avoid a painful three-hour-long installation from
scratch after every crash, and to ease a possible deployment of multiple machines,
we used the [Ansible][ansible] automation tool.

[kubernetes]: https://kubernetes.io/
[rancher]: https://rancher.com/
[ansible]: https://www.ansible.com/

# Overview of the environment

## How the host works

In the working server, the only host of our deployment, there are several
virtualization layers. Our Ubuntu machine actually runs over the Virtualization
technology of the VPS provider.

Over Ubuntu, Rancher runs in a Docker container. From this point, everything is
a Docker container. Rancher manages the containers providing Kubernetes, and
they themselves manage the services that we run in Kubernetes.

![Server Overview](https://www.neze.fr/public/acn/nano/server-overview.svg)

## How we control all of these small workers

The control unit to setup and control this system is completely decentralized
thanks to SSH (secure shell access) and APIs (application programming interfaces
giving administration access through https).

Ansible basically connects to the managed hosts via SSH to enforce the
configuration we specified, and KubeControl interacts with the API of
Kubernetes to manage web services.

![Global Overview](https://www.neze.fr/public/acn/nano/global-overview.svg)

# A simple use case

*Load Balancer using Kubernetes Deployment*

We created a super simple webservice in a docker image from the [Docker Get Started][docker-get-started]
tutorial. It actually shows a minimal web page with the hostname of the server.
The hostname just allows us to differentiate the webservice instances and highlight
load balancing.

[docker-get-started]: https://docs.docker.com/get-started/part2

Then we created a Kubernetes instance in Rancher on which we intend to launch
our sample web service. The Kubernetes deployment is fully automatized with
ansible, modulo a few human interactions that could also be automatic, and is
demonstrated below.

Finally, we run our web service in Kubernetes. Fully automatized as well, this
deployment is actually three parts at three levels.

* The web service is abstracted in Kubernetes as a **deployment**.

* Underneath this abstraction layer, there are actually as many **pods** as
  desired **replicas**. One pod is one instance of the service, i.e., one
  container in our case but possibly several containers in other web services.
  In other words, a pod is the finest granularity you can have in Kubernetes
  where everything breaks down to **pods**.

  There are then in the first demo step 2 instances of our web service running
  in separate containers.

* Over this is the availability layer. We **expose** our web service through
  a load-balancing service making it publicly available.

In the demonstration we also tried **scaling** our service, i.e., only changing
the number of replicas of our already running service. When doing this in
Kubernetes we can see pods being created and stopped depending on the number
of desired replicas.

![Kubernetes Overview](https://www.neze.fr/public/acn/nano/kubernetes.svg)

# Demo

Now let's go over the installation steps and try to understand how everything
fits into the whole scheme.

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

[Link to the demo](https://asciinema.org/a/161756)

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

[Link to the demo](https://asciinema.org/a/161759)

The Rancher interface is publicly accessible so the first setup step configures
authentication in Rancher. Once Rancher is launched and has authentication, the
login page is accessible.

![Authentication](https://www.neze.fr/public/acn/nano/rancher-install-after.png)

Next step in the Ansible script is about setting up and activating a Kubernetes environment, i.e., a
container platform in rancher that will be managed by Kubernetes. Once the
environment is setup in Rancher, we can see that Rancher is actually starting
every required element of Kubernetes.

![Kubernetes](https://www.neze.fr/public/acn/nano/kubernetes-install.png)

Once Kubernetes was started by Rancher, its web interface can also be accessed
and it shows the running backbone services that are necessary to have a working
instance of Kubernetes.

![Kubernetes UI](https://www.neze.fr/public/acn/nano/kubernetes-install-after.png)

With only this setup, we only have the controler part of Kubernetes. Ansible registers
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

[Link to the demo](https://asciinema.org/a/161747)

## Step 5 - Run a simple web service with load balancing

Ansible first checks if the web service we want is already running and accessible.
Then, it can run the service, make it accessible (expose it) or scale it if
the number of replicas is different in the configuration.

<div style="text-align:center">
  <script src="https://asciinema.org/a/161750.js" id="asciicast-161750" async></script>
</div>

[Link to the demo](https://asciinema.org/a/161750)

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

[Link to the demo](https://asciinema.org/a/161751)

The User Interface shows more replicas, and when you access the web service you
can see three new distinct instances.

![Kube UI](https://www.neze.fr/public/acn/nano/kubernetes-helloacn-scaling-after.png)

![Kube Service](https://www.neze.fr/public/acn/nano/kubernetes-helloacn-service-pjmqn.png)

![Kube Service](https://www.neze.fr/public/acn/nano/kubernetes-helloacn-service-rssdv.png)

![Kube Service](https://www.neze.fr/public/acn/nano/kubernetes-helloacn-service-wflhd.png)

# Lessons learned

![Lessons learned](https://www.neze.fr/public/acn/nano/lessons-learned.svg)

# Do it yourself !

A lot of our work is actually available in a public [git repository][git-cn].
We did not describe everything in this post but most of it can be understood from
the config files and man pages of ansible, kubernetes, etc.

[git-cn]: https://framagit.org/cn/public-server-admin
