# Lab 1 — Your first virtual machine

Pair: Bostan Temirlan / No Pair

Machine: Temirlan (Host),  Innotech (Guest).

Date: 23.10.2026

## What I did

1. Created a new Virtual Machine in VirtualBox and installed Ubuntu Server 26.04 LTS (console only).
2. Configured Port Forwarding in VirtualBox (Host Port 2222 to Guest Port 22) to enable SSH access from PowerShell.
3. Connected to the guest via SSH and saved the release information:

```bash
ssh -p 2222 bostan@127.0.0.1
lsb_release -a 
```
4. Powered off the VM and created a snapshot named clean-install.

5. Intentionally broke the OS configuration by removing the hostname file:

```bash
sudo rm /etc/hostname
sudo reboot
```

6. Reconnected via SSH and verified that the hostname file was missing:

```bash
cat /etc/hostname
```
7. Powered off the VM and rolled back to the clean-install snapshot using VirtualBox Snapshot Manager.

8. Booted the VM, reconnected via SSH, and confirmed the hostname was restored:
```bash
cat /etc/hostname
```

## Result

The virtual machine was successfully set up, broken by removing critical host configuration, and fully restored using the clean-install snapshot rollback./

**Resource Justification:**
I allocated 2 GB of RAM, 3 vCPUs, and a 25 GB dynamic disk to this VM. I chose these values based on my host machine's total specs measured in Lab 0 (Intel Core i5-11400H with 6 cores / 12 threads, 8 GB total RAM). Since Windows 11 uses about 4.5 GB of RAM at idle, allocating 2 GB to the VM leaves roughly 1.5 GB free for the host to remain stable, while giving the guest enough resources to run a console-only OS smoothly.


## What did not work the first time

Initially, my SSH connection attempt via ssh -p 2222 bostan@127.0.0.1 failed with "Connection refused" because VirtualBox was closed or the VM was not running. I realized that Port Forwarding requires the virtual machine to be actively running in the background, so I started the VM first and then successfully connected.

## Evidence

- [evidence/vm-settings.png](evidence/vm-settings.png) — screenshot of VirtualBox settings showing 2 GB RAM, 3 vCPUs, and 25 GB disk allocation.
- [evidence/guest-release.txt](evidence/guest-release.txt) — terminal output of `lsb_release -a` proving Ubuntu Server is installed inside the guest.
- [evidence/broken.png](evidence/broken.png) — screenshot showing `cat: /etc/hostname: No such file or directory`, proving system breakage.
- [evidence/snapshot-list.png](evidence/snapshot-list.png) — snapshot list taken after rollback and verifying hostname restoration.
