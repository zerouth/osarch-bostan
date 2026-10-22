# Lab 1 — Your first virtual machine

Pair: Bostan Temirlan (No Pair)                    Driver first half: -
Machine: Temirlan (Host), lab01-ubuntu (Guest)
Date: 23.10.2026

## What I did

1. Created a new Virtual Machine in VirtualBox and installed Ubuntu Server 26.04 LTS (console only).
2. Configured Port Forwarding in VirtualBox (Host Port 2222 to Guest Port 22) to enable SSH access from PowerShell.
3. Connected to the guest via SSH and saved the release information:
```bash
ssh -p 2222 bostan@127.0.0.1
lsb_release -a

1.Powered off the VM and created a snapshot named clean-install.

2.Intentionally broke the OS configuration by removing the hostname file:

Bash
sudo rm /etc/hostname
sudo reboot
1.Reconnected via SSH and verified that the hostname file was missing:

Bash
cat /etc/hostname
1.Powered off the VM and rolled back to the clean-install snapshot using VirtualBox Snapshot Manager.

Resource Justification:
I allocated 2 GB of RAM, 3 vCPUs, and a 25 GB dynamic disk to this VM. I chose these values based on my host machine's total specs measured in Lab 0 to ensure the guest operates smoothly while leaving enough host memory and CPU capacity for Windows to run without freezing.

## Result

The virtual machine was successfully set up, broken by removing critical host configuration, and fully restored using the clean-install snapshot rollback.

## What did not work the first time

Initially, my SSH connection attempt via ssh -p 2222 bostan@127.0.0.1 failed with "Connection refused" because VirtualBox was closed or the VM was not running. I realized that Port Forwarding requires the virtual machine to be actively running in the background, so I started the VM first and then successfully connected.

## Evidence

- [evidence/vm-settings.png](evidence/vm-settings.png) — screenshot of VirtualBox settings showing 2 GB RAM, 3 vCPUs, and 25 GB disk allocation.

- [evidence/guest-release.txt](evidence/guest-release.txt) — terminal output of `lsb_release -a` proving Ubuntu Server is installed inside the guest.

- [evidence/broken.png](evidence/broken.png) — screenshot showing `cat: /etc/hostname: No such file or directory`, proving system breakage.

- [evidence/snapshot-list.png](evidence/snapshot-list.png) — screenshot of the VirtualBox Snapshot Manager showing Current State under clean-install.
