# Lab 2 — A Windows guest, and a network between them

Pair: Bostan Temirlan (No Pair)

Driver first half: Bostan

Machine: Host (Intel Core i5-11400H, 8 GB RAM, 6 cores / 12 threads)

Guests: Innotech (Ubuntu Server 26.04) + lab02-windows (Windows 11 Enterprise eval)

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

1. **Inbound ping blocked by Windows Defender Firewall:**
   - **What I saw:** Pinging `lab02-windows` (10.0.2.4) from Ubuntu (`Innotech`) resulted in 100% packet loss and request timeouts.
   - **What it turned out to be:** Windows Defender Firewall classifies new virtual network interfaces under the Public network profile by default, which silently drops incoming ICMPv4 echo requests (Type 8).
   - **What I did:** Rather than disabling the entire firewall (which violates course security requirements and incurs a mark penalty), I opened PowerShell as Administrator on the Windows guest and created an explicit inbound rule allowing ICMPv4:
     `New-NetFirewallRule -DisplayName "Allow ping in (ICMPv4)" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow`

2. **Host memory pressure under standard 4 GB allocation:**
   - **What I saw:** Assigning 4 GB of RAM to the Windows guest while Ubuntu was running caused severe host stutter, mouse input lag, and excessive SSD disk swapping.
   - **What it turned out to be:** My physical host only has 8 GB of RAM, and Windows 11 host background processes already consume ~7.0 GB at idle (leaving only ~799 MB available). Allocating 4 GB to Ubuntu and 4 GB to Windows created extreme physical memory exhaustion.
   - **What I did:** Scaled the Windows 11 virtual machine allocation down to 2 GB for stable operation, and intentionally aborted the physical execution of the 10 GB (5 GB + 5 GB) overcommitment stress test to prevent host system failure.

## Evidence

- [evidence/ipconfig-windows.txt](evidence/ipconfig-windows.txt) — Windows guest IP address and configuration
- [evidence/ip-addr-linux.txt](evidence/ip-addr-linux.txt) — Ubuntu guest IP address configuration
- [evidence/ping-both-ways.txt](evidence/ping-both-ways.txt) — ping evidence in both directions and to the internet
- [evidence/host-memory-before.png](evidence/host-memory-before.png) — host Task Manager memory view before launching guests
- The `host-memory-after.png` screenshot could not be captured because allocating more than 2 GB crashed and froze the host operating system completely.
