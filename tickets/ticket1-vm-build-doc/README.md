# Ticket 1 — New developer starts Monday, needs a test machine

Pair: Bostan Temirlan (No Pair)  
Machine: Host (Intel Core i5-11400H, 8 GB RAM, 6 cores / 12 threads), Guests: Innotech (Ubuntu 24.04) + lab02-windows (Windows 11)
Date: 05.11.2026 (Second Try)

## 1. What was asked
"Hi, we have someone starting on Monday and he needs a test computer set up. Nothing special, just so he can try things without breaking anything. Can you write down how to do it so I can do the next one myself? Thanks"

## 2. What was actually needed
* **Missing context:** The request omits the specific OS stack (Linux for backend, Windows for tools), the physical host's 8 GB RAM limitation, and whether the machine needs internet access or network isolation. 
* **Where it was wrong:** "Nothing special" severely underestimates the complexity. A proper setup requires configuring UEFI, virtual TPM, NAT Networks, and strict resource limits to prevent host crashes. It also ignores the target audience: the office manager needs explicit, non-technical instructions, not developer jargon.
* **Licensing:** The request assumes any OS can be installed. In a corporate environment, we must use strictly legal trial images (Ubuntu 24.04 LTS and Windows 11 Enterprise Evaluation) to maintain compliance.
* **Assumptions:** I assumed strict allocations of 2 GB RAM per VM (based on the host idling at 5.8 GB measured in Lab 2) and mandated VirtualBox snapshots to fulfill the "without breaking anything" requirement.

* **Questions for Aigerim:** What tech stack does the developer need (Linux backend or Windows tools)? What are the hardware specs of the target laptop? Does the VM need external internet or complete network isolation?

## 3. What I did
1. Selected Oracle VirtualBox over Hyper-V or VMware because it is open-source, easily scriptable, and natively supports the required `NAT Network` isolation without complex Windows networking setups.
2. Downloaded legal Evaluation ISOs for Ubuntu Server and Windows 11.
3. Built both VMs with 2 vCPUs, exactly 2048 MB RAM.
4. Created a `NAT Network` (`osarch-net`) and attached both VMs to allow internet and inter-VM communication.
5. Opened Windows Defender Firewall via PowerShell to allow ICMPv4 pinging.
6. Took a `clean-install` snapshot for instant rollback.

## 4. Evidence
- [evidence/01-nеw-vm-wizard.png](evidence/01-nеw-vm-wizard.png) — shows 2 vCPU and memory limits during creation
- [evidence/02-disk-settings.png](evidence/02-disk-settings.png) — shows dynamically allocated disk choice
- [evidence/03-network-adapter.png](evidence/03-network-adapter.png) — shows the NAT Network assignment
- [evidence/04-guest-uname.txt](evidence/04-guest-uname.txt) — proves Ubuntu 24.04 OS identity
- [evidence/05-ping-between-guests.txt](evidence/05-ping-between-guests.txt) — proves network connectivity
- [evidence/06-snаpshot-list.png](evidence/06-snаpshot-list.png) — proves a clean rollback snapshot exists for both VMs

## What did not work the first time
While writing the documentation, I initially forgot to specify that Windows 11 requires "Enable EFI" and "Virtual TPM 2.0" in VirtualBox. When testing the build steps, the Windows installer threw an "Unsupported Hardware" error. I had to discard the VM, update the documentation with the strict TPM/EFI requirements, and rebuild it successfully.

## 5. What I would do differently
Next time, instead of giving the office manager a manual GUI guide, I would provide an automated Vagrantfile script. Running one script eliminates human error and guarantees identical configurations every time.
