---
layout: post
title: Notes about encrypted storage
category:
 - computer-science
 - notes
toc: true
author: Clément Durand
---

*Notes from the last time I had to create and use an encrypted usb key.*

---

You need to get the name of your device, and of the partition you will create.

```bash
dev=sdc
part=sdc1
```

# Creating a cryptodevice

## Create a partition on the device

```bash
fdisk /dev/$dev
```

## Format the partition as LUKS encrypted fs

```bash
cryptsetup luksFormat /dev/$part           # will prompt for a passphrase
cryptsetup luksFormat /dev/$part <keyfile> # will use the key file to encrypt
```

## Open the partition

```bash
cryptsetup luksOpen /dev/$part $part
cryptsetup luksOpen /dev/$part $part --key-file=<keyfile>
```

This creates a virtual partition in `/dev/mapper/$part`.

## Create a filesystem in the partition

```bash
mkfs.ext4 /dev/mapper/$part
```

## Mount the partition

```bash
mkdir -p /mnt/usb && mount /dev/mapper/$part /mnt/usb
```

You can now use `/mnt/usb` as a normal storage device. It will be encrypted on the fly.

# Opening a cryptodevice

Using the last steps of the device creation, the opening becomes&nbsp;:

```bash
cryptsetub luksOpen /dev/$part $part
mkdir -p /mnt/usb && mount /dev/mapper/$part /mnt/usb
```

# Closing a cryptodevice

To eject your device properly, the cleanest way is to do everything step by step&nbsp;:

```bash
umount /mnt/usb
cryptsetup luksClose /dev/mapper/$part
eject /dev/$dev
```
