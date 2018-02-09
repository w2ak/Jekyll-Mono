---
layout: post
title: NanoProject
toc: false
asciinema: true
author: Clément Durand & Carolina De Senne Garcia
date: 2018-02-09
permalink: /projects/ansible-rancher-kubernetes/

---

# Demo

## Step 1 - Start from a clean server

* Install Ubuntu on the server

  ![OS Install](/share/acn/nano/server-os-install.png)

* Post-install, the server should refuse http

  ![HTTP Refused](/share/acn/nano/server-os-install-after.png)

## Step 2 - Install and configure the server

* Launch the initial installation of the server

  <script src="https://asciinema.org/a/161756.js" id="asciicast-161756" async></script>

* During the installation, basic setup (users accounts, programs) is realized
  The nginx web server should get installed.

  ![Nginx Index](/share/acn/nano/server-install-nginx.png)

* Post installation, the nginx proxy was configured and the default webpage copied

  ![Perdu](/share/acn/nano/server-install-after.png)

## Step 3 - Install, launch and configure Rancher

* Before installing rancher, there is nothing behind the nginx proxy

  ![Bad Gateway](/share/acn/nano/rancher-install-before.png)

* Launch the rancher setup

  <script src="https://asciinema.org/a/161759.js" id="asciicast-161759" async></script>

* The script first configures authentication

  ![Authentication](/share/acn/nano/rancher-install-after.png)

* Then, it creates an instance of Kubernetes

  ![Kubernetes](/share/acn/nano/kubernetes-install.png)

* Once the instance of Kubernetes is up, the user interface shows the basic services of the controler

  ![Kubernetes UI](/share/acn/nano/kubernetes-install-after.png)

* One host is registered to Kubernetes as the only available machine
  Kubernetes progressively sets the host up and launch minimal services

  ![Kubernetes Host](/share/acn/nano/kubernetes-install-host.png)

  ![Kubernetes Host Up](/share/acn/nano/kubernetes-install-host-after.png)

## Step 4 - Configure kubectl to control Kubernetes

* The install script gets a token and configures kubectl on the host

  <script src="https://asciinema.org/a/161747.js" id="asciicast-161747" async></script>

## Step 5 - Run a simple web service with load balancing

* The install script has kubectl running the service for us

  <script src="https://asciinema.org/a/161750.js" id="asciicast-161750" async></script>

* Afterwards, the Kubernetes UI shows services and two instances of the webservice are accessible

  ![KubeUI](/share/acn/nano/kubernetes-helloacn-after.png)

  ![Kube Service](/share/acn/nano/kubernetes-helloacn-service-65qsk.png)

  ![Kube Service](/share/acn/nano/kubernetes-helloacn-service-ng4m4.png)

## Step 6 - Try some scaling

* Here, the script has kubectl changing the number of replicas

  <script src="https://asciinema.org/a/161751.js" id="asciicast-161751" async></script>

* Afterwards, the Kubernetes UI shows 3 more pods that are also accessible via http

  ![Kube UI](/share/acn/nano/kubernetes-helloacn-scaling-after.png)

  ![Kube Service](/share/acn/nano/kubernetes-helloacn-service-pjmqn.png)

  ![Kube Service](/share/acn/nano/kubernetes-helloacn-service-rssdv.png)

  ![Kube Service](/share/acn/nano/kubernetes-helloacn-service-wflhd.png)
