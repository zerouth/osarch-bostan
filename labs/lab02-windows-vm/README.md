# Lab 2 — A Windows guest, and a network between them

Pair: Bostan Temirlan (No Pair)

Driver first half: Bostan

Machine: Host (Intel Core i5-11400H, 8 GB RAM, 6 cores / 12 threads), Guests: Innotech (Ubuntu Server 26.04) + lab02-windows (Windows 11 Enterprise eval)

Date: 03.11.2026

## What I did

1. Installed Windows 11 Enterprise evaluation VM (`lab02-windows`) with 2 vCPUs, 2 GB RAM, UEFI, and vTPM 2.0.
2. Connected both VMs to VirtualBox `NAT Network` (`osarch-net`) for inter-guest communication and internet access, as bridged mode fails on campus Wi-Fi due to MAC filtering and standard NAT isolates guests behind separate routers.
3. Allowed inbound ICMPv4 Type 8 traffic in Windows via PowerShell (`New-NetFirewallRule`) to enable ping without disabling Windows Defender Firewall.
4. Verified bidirectional ping between guests and out to the internet (`ubuntu.com`).
5. Measured baseline host RAM (7.0 GB / 90% in use on an 8 GB host) and kept allocations at safe limits (Ubuntu 4 GB, Windows 2 GB) to avoid catastrophic host lockup.

## Network diagram

                     Internet
                        |
            Host Laptop (Windows 11)
                        |
     [VirtualBox NAT Network: osarch-net]
             |                      |
          Innotech            lab02-windows
          10.0.2.3               10.0.2.4

## Result


| Metric | Before (Guests Off) | After (Both Overcommitted) |
| :--- | :--- | :--- |
| **Host RAM in use** | 7.0 GB | N/A (Aborted) |
| **Available** | 799 MB | N/A (Aborted) |
| **Committed / Swap used** | 12.8 / 24.8 GB | N/A (Aborted) |
| **What I noticed** | Baseline Windows 11 idle memory state is already at 90% utilization. | Launching 10 GB of virtual RAM on a host with only 799 MB available physical RAM would cause severe swap thrashing and freeze the host OS completely. The experiment was safely aborted to preserve system stability. |

## What did not work the first time

1. Host freezing under 4 GB VM allocation: The lab guide recommended 4 GB RAM for the Windows 11 guest[cite: 8]. With Ubuntu already assigned 4 GB and the host having only 8 GB total (with ~7.0 GB in use), allocating 4 GB caused total host freezing[cite: 8]. I resolved this by scaling the Windows VM allocation down to 2 GB for stable operation[cite: 8].

2. Firewall dropping ICMP echo: Pinging from Ubuntu (Innotech) to Windows (lab02-windows) timed out with 100% loss due to Windows Defender Firewall blocking ICMP on the Public network profile[cite: 8]. I resolved it by creating an explicit inbound rule via New-NetFirewallRule instead of disabling the firewall[cite: 8].

## Evidence

- [evidence/](evidence/) — one line per file on what it proves
- [evidence/](evidence/)
