# Lab 1 — Your first virtual machine

Pair: Bostan Temirlan (No Pair)                    Driver first half: -
Machine: Temirlan (Host), lab01-ubuntu (Guest)
Date: 23.10.2026

## What I did

1.Created a new Virtual Machine in VirtualBox and installed Ubuntu Server 26.04 LTS (console only).

2.Configured Port Forwarding in VirtualBox (Host Port 2222 to Guest Port 22) to allow SSH access from Windows PowerShell.

3.Connected to the guest via SSH and saved the release information using the command:
lsb_release -a

4.Shut down the virtual machine and took a snapshot named clean-install.

5.Deleted the system hostname configuration file to intentionally break the OS:
sudo rm /etc/hostname
sudo reboot

6.Reconnected via SSH and verified that the hostname file was missing using:
cat /etc/hostname

7.Powered off the VM and restored the clean-install snapshot via VirtualBox Snapshot Manager.

Resource Justification:
I allocated 2 GB of RAM, 3 vCPUs, and a 25 GB dynamic disk to this VM. I chose these values based on my host machine's specifications to ensure the guest operates smoothly while leaving enough host RAM and CPU capacity for Windows to run without freezing.

## Result

The virtual machine was successfully set up, broken by removing critical host configuration, and fully restored using the clean-install snapshot rollback.

## What did not work the first time

Initially, my SSH connection attempt via ssh -p 2222 bostan@127.0.0.1 failed with "Connection refused" because VirtualBox was closed or the VM was not running. I realized that Port Forwarding requires the virtual machine to be actively running in the background, so I started the VM first and then successfully connected.

## Evidence

- [evidence/](evidence/) — one line per file on what it proves

- [evidence/](vm-settings.png/) — shows the configured 2 GB RAM, 3 vCPUs, and disk allocation in VirtualBox.

- [evidence/](guest-release.txt/) — SSH terminal output verifying the guest is running Ubuntu Server.

- [evidence/](broken.png/) — screenshot showing the file missing error after removing /etc/hostname.

- [evidence/](snapshot-list.png/) — screenshot showing Current State restored to the clean-install snapshot.
