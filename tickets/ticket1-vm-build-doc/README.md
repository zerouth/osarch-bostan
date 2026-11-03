# Ticket 1 — VM build document

## 1. What was asked
> "From: Aigerim T. (Office Manager)
> Subject: test machine for new dev
> Hi, we have someone starting on Monday and he needs a test computer set up. Nothing special, just so he can try things without breaking anything. Can you write down how to do it so I can do the next one myself? Thanks"

## 2. What was actually needed
What the request left out: It does not specify the OS (a developer needs both Linux and Windows), the host laptop's memory/disk limits, or network requirements (whether it needs internet or isolated networking).
Where the request is wrong: "Nothing special" is incorrect; setting up VMs requires BIOS virtualization, specific RAM limits, and snapshot configuration.
What I would have asked Aigerim: What OS does the developer need? How much RAM does the host laptop have? Does the VM need internet access?
What I assumed instead: I assumed dual VMs (Ubuntu Server and Windows 11), a strict 2 GB RAM limit per guest (since our host laptops only have 8 GB total and idle around 7 GB), and a NAT Network to provide internet while keeping guests securely in the same subnet. I also assumed the need for immediate snapshots to satisfy the "without breaking anything" requirement.

## 3. What I did
1. Installed Ubuntu Server 24.04 and Windows 11 Enterprise Evaluation in VirtualBox.
2. Allocated exactly 2048 MB RAM and 2 vCPUs for each to prevent the 8 GB host from crashing.
3. Used Dynamically allocated disks (25 GB Linux, 64 GB Windows) to save physical space.
4. Created a `NAT Network` (`osarch-net`) for both guests to allow them to communicate and reach the internet.
5. In Windows, allowed inbound ICMPv4 Type 8 via PowerShell to enable ping tests without disabling the firewall.
6. Shut down both VMs and took a `clean-install` snapshot for instant rollback.

| Setting | Default | Mine | Why |
| :--- | :--- | :--- | :--- |
| **RAM** | 4 GB (Win) | 2 GB | Host only has 8 GB total; 4 GB causes complete host freeze. |
| **Disk** | Fixed | Dynamically allocated | Saves real SSD space on the laptop. |
| **Network** | NAT | NAT Network | Allows guests to ping each other while keeping internet access. |

## 4. Evidence
- [evidence/01-new-vm-wizard.png](evidence/01-new-vm-wizard.png) — shows CPU and RAM limits during creation
- [evidence/02-disk-settings.png](evidence/02-disk-settings.png) — shows dynamically allocated disk selection
- [evidence/03-network-adapter.png](evidence/03-network-adapter.png) — shows NAT Network mode selection
- [evidence/04-guest-uname.txt](evidence/04-guest-uname.txt) — output of `uname -a` and `lsb_release -a` inside Linux
- [evidence/05-ping-between-guests.txt](evidence/05-ping-between-guests.txt) — ping output proving guests can see each other and the internet
- [evidence/06-snapshot-list.png](evidence/06-snapshot-list.png) — shows the clean-install snapshot for rollback

## 5. What I would do differently
Next time, I would write an automated script (like a Vagrantfile) instead of giving the office manager a manual GUI guide, to prevent them from accidentally allocating too much RAM and freezing the machine.
