# Lab 6 — Live processes and memory pressure

Pair: Bostan Temirlan (No Pair) · Date: 15–16.11.2026 · Hypervisor: VirtualBox

Machine: Host Acer Nitro AN515-57 (Windows 11, 8 GB RAM). Guests: VM "Windows" (Windows 11 Enterprise Evaluation, 2048 MB, 2 vCPU) and VM "Ubuntu" (Ubuntu Server 26.04.1 LTS, kernel 7.0.0-38-generic, hostname Innotech, 3 vCPU, normally 4096 MB, lowered to 2048 MB for Part 2).

Time note: Windows screenshots show Almaty time (UTC+5). The Ubuntu clock is UTC (`timedatectl`: `Time zone: Etc/UTC`), so every Ubuntu time below is UTC: 19:56 UTC on 15.11 = 00:56 on 16.11 in Almaty.

## Part 1 — One process, three tools

Process chosen: **VBoxService** (`VBoxService.exe` on Windows, `/usr/sbin/VBoxService` on Ubuntu). It is the VirtualBox Guest Additions service, so the same program runs on both guests and can be compared directly.

Ubuntu had no Guest Additions, so the service was installed first (see "What did not work"):

```
$ sudo apt install -y virtualbox-guest-utils
$ sudo systemctl start virtualbox-guest-utils
$ pgrep -a VBoxService
2351 /usr/sbin/VBoxService
```

The laptop and the Ubuntu guest were restarted later, so the final numbers below are from new instances: Windows PID **1876** (started 00:30:40), Ubuntu PID **1194**. Task Manager and Process Explorer show the same PID 1876 in the same boot. Ubuntu is a separate process of the same program.

### Task Manager (Windows, 16.11, about 00:34)

Details tab, columns added: PID, Working set (memory), Memory (active private working set), Commit size, Handles, Threads. Screenshot: `evidence/task-manager.png`.

### Process Explorer (Windows, 16.11, 00:39–00:47)

Run as administrator. Columns added: Private Bytes, Working Set, WS Private, Handles, Threads. Lower pane: Handles. Screenshots: `evidence/process-explorer.png` (tree, columns, handles pane) and `evidence/process-explorer-image.png` (Properties → Image tab).

From the Image tab:

```
Command line:  C:\WINDOWS\System32\VBoxService.exe
Parent:        services.exe(860)
User:          NT AUTHORITY\SYSTEM
Started:       12:30:40 AM  11/16/2026
```

The handles pane lists, among others, `File \Device\VBoxGuest`, the driver the service talks to, and many `Key HKLM\...` registry keys.

### htop and ps (Ubuntu, 19:52 UTC)

`htop` → F5 tree, F3 search `VBoxService`. Screenshot: `evidence/htop.png` (PID 1194, root, VIRT 285M, RES 3792, SHR 3380, CPU% 0.0, MEM% 0.1; the green rows 1197–1201 under it are its threads).

```
$ ps -o pid,ppid,user,rss,vsz,nlwp,cmd -p 1194
    PID    PPID USER       RSS    VSZ NLWP CMD
   1194       1 root      3796 292100    9 /usr/sbin/VBoxService
$ sudo ls /proc/1194/fd | wc -l
5
$ sudo ls -l /proc/1194/fd | head
total 0
lrwx------ 1 root root 64 Nov 15 19:53 0 -> /dev/null
lrwx------ 1 root root 64 Nov 15 19:53 1 -> /dev/null
lrwx------ 1 root root 64 Nov 15 19:53 2 -> /dev/null
lrwx------ 1 root root 64 Nov 15 19:53 3 -> /dev/vboxguest
lrwx------+1 root root 64 Nov 15 19:53 4 -> socket:[13225]
```

### Comparison table

| | Task Manager | Process Explorer | htop / ps |
| --- | --- | --- | --- |
| PID | 1876 | 1876 | 1194 |
| Parent (name and PID) | — (not shown) | services.exe (860) | systemd (PPID 1) |
| "Memory" as shown by default | 1,152 K (Memory (active private working set)) | Private Bytes 2,448 K and Working Set 6,576 K (default columns) | RES 3792 K, MEM% 0.1 |
| Private memory | Commit size 2,392 K | Private Bytes 2,448 K | no column |
| Working set / RES | 9,200 K | 6,576 K | RES 3792 K (ps RSS 3796 K), of which SHR 3380 K |
| Virtual size | not shown | not added | VIRT 285M (ps VSZ 292100 K) |
| Handles / file descriptors | 202 | 202 (listed in the lower pane) | 5 fd |
| Threads | 14 | 14 | 9 (ps NLWP; htop shows them as separate rows) |

### Where the tools disagree

- **Task Manager does not show the parent at all.** Process Explorer shows it in the tree and in the Image tab (services.exe, 860, because VBoxService is a Windows service started by the Service Control Manager). On Linux the parent is PID 1, systemd, which started the `virtualbox-guest-utils` unit.
- **The same number under different names.** Task Manager "Commit size" (2,392 K) and Process Explorer "Private Bytes" (2,448 K) are the same counter, the private memory the process has committed. Task Manager "Memory (active private working set)" and Process Explorer "WS Private" are also the same thing. The values are not equal because the screenshots were taken minutes apart on a live process: the working set dropped from 9,200 K to 6,576 K in between, most likely because Windows trimmed the working set of the idle service. htop has no column for committed private memory at all.
- **Task Manager's default "Memory" is not the same as htop's RES.** Task Manager shows only private pages in RAM (1,152 K). htop RES counts every page in RAM, including shared libraries: here 3380 K of the 3792 K RES is SHR, shared memory.
- **VIRT is not memory in use.** VIRT 285M is the whole reserved address space; only 3.7 MB of it is actually in RAM (RES).
- **Handles 202 vs 5 file descriptors.** A Windows handle points to any kernel object: files, registry keys, events, threads, sections. A Linux fd is only an open file, device or socket. The Linux service has `/dev/null` three times (stdin, stdout, stderr), `/dev/vboxguest` (the driver) and one socket.
- **Threads are shown differently.** Windows tools show a count (14). htop lists each thread as its own row with its own ID (1197, 1198, …) under the process; `ps` gives the count as NLWP (9).

## Part 2 — Memory pressure

Guest RAM: 4096 MB lowered to **2048 MB** in Settings → System while the VM was off, after snapshot `before-lab6` (the guest then sees 1.6 Gi). Swap: **none** at first (`Swap: 0B`, `swapon --show` printed nothing). Runs 1–4 were done without swap. For run 5 I added a temporary 1 GB swap file to watch the swap figure the brief asks about.

```
$ free -h
               total        used        free      shared  buff/cache   available
Mem:           1.6Gi       381Mi       783Mi       1.1Mi       623Mi       1.2Gi
Swap:             0B          0B          0B
$ swapon --show
$ timedatectl
                Local time: Sun 2026-11-15 19:56:26 UTC
                 Time zone: Etc/UTC (UTC, +0000)
```

### Steps, in order

Recording terminal (second SSH session):

```bash
cd ~ && mkdir -p lab06 && cd lab06
{ echo '$ free -h'; echo "=== BEFORE $(date) ==="; free -h; } > memory-pressure.txt
while true; do echo "=== $(date +%T) ==="; free -h; sleep 3; done | tee -a memory-pressure.txt
```

Load terminal:

```bash
# 1. as in the guide: crashed with SIGILL (see "What did not work")
date +%T; stress-ng --vm 2 --vm-bytes 70% --timeout 60s; date +%T
date +%T; stress-ng --vm 2 --vm-bytes 90% --timeout 60s; date +%T
date +%T; stress-ng --vm 2 --vm-bytes 120% --timeout 90s; date +%T
# 2. same steps with a method that runs on this virtual CPU
date +%T; stress-ng --vm 1 --vm-bytes 50% --vm-method flip --timeout 10s; date +%T
date +%T; stress-ng --vm 2 --vm-bytes 70% --vm-method flip --timeout 60s; date +%T
date +%T; stress-ng --vm 2 --vm-bytes 90% --vm-method flip --timeout 60s; date +%T
date +%T; stress-ng --vm 2 --vm-bytes 120% --vm-method flip --timeout 90s; date +%T
```

Then `Ctrl+C` in the recording terminal and:

```bash
{ echo '$ free -h'; echo "=== AFTER $(date) ==="; free -h; } >> memory-pressure.txt
```

The 120% run filled the memory but the kernel killed nothing, so three more runs without swap followed (all in `memory-pressure.txt`, each marked with its own command line):

```bash
# run 2: workers keep their memory instead of releasing it
date +%T; stress-ng --vm 2 --vm-bytes 150% --vm-method flip --vm-keep --timeout 90s; date +%T
# run 3: one process asks for 1.5 GB at once
date +%T; python3 -c "a = b'x' * (1500 * 1024 * 1024)"; date +%T
# run 4: the same, inside a cgroup limited to 400 MB, no swap
date +%T; sudo systemd-run --scope -p MemoryMax=400M -p MemorySwapMax=0 python3 -c "a = b'x' * (1500 * 1024 * 1024)"; date +%T
```

Run 5, with a temporary 1 GB swap file (removed afterwards):

```bash
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
{ echo '$ swapon --show'; swapon --show; echo '$ free -h'; echo "=== BEFORE run 5 (1 GB swap file) $(date) ==="; free -h; } >> memory-pressure.txt
date +%T; stress-ng --vm 2 --vm-bytes 120% --vm-method flip --timeout 60s; date +%T
# afterwards
sudo swapoff /swapfile
sudo rm /swapfile
```

For runs 3, 4 and 5 the recording loop also called `sync`, so the file is written to disk every 3 seconds even if the guest hangs.

### Before / during / after

Run 5, stress-ng 120% with 1 GB swap:

| | Before (20:47:38) | During (worst, 20:49:03) | After (20:50:25) |
| --- | --- | --- | --- |
| Available | 1.2Gi | 647Mi (lowest 457Mi at 20:48:59) | 1.2Gi |
| Swap used | 0B | 294Mi | 24Ki |

Run 1, stress-ng 120% without swap:

| | Before (19:58:23) | During (worst, 20:06:49) | After (20:08:50) |
| --- | --- | --- | --- |
| Available | 1.2Gi | 61Mi | 1.2Gi |
| Swap used | 0B (no swap) | 0B (no swap) | 0B (no swap) |

### What happened

```
$ date +%T; stress-ng --vm 2 --vm-bytes 120% --vm-method flip --timeout 90s; date +%T
20:05:34
stress-ng: info:  [2014] setting to a 1 min 30 secs run per stressor
stress-ng: info:  [2014] dispatching hogs: 2 vm
stress-ng: info:  [2015] vm: using 611.54MB per stressor instance (total 1.19GB of 1018.98MB available memory)
stress-ng: info:  [2014] passed: 2: vm (2)
stress-ng: info:  [2014] failed: 0
stress-ng: info:  [2014] successful run completed in 1 min 46.71 secs
20:07:21
```

- **70% (20:02:15–20:03:40):** available went down to 614Mi. The run took 1 min 25 s instead of 60 s, and the recording has a gap from 20:02:17 to 20:03:40: the `free` loop, which should print every 3 s, did not get CPU time for 83 s.
- **90% (20:04:01–20:05:11):** available down to 423Mi (20:04:21). buff/cache shrank from 437Mi to 371Mi: the kernel dropped file cache to make room.
- **120% (20:05:34–20:07:21):** available fell to **74Mi at 20:05:39** and dropped to 61–72Mi again at 20:05:43, 20:05:54 and 20:06:49 (in between it rose for a moment while stress-ng restarted its memory blocks). Swap did not grow because there is no swap, so the only thing the kernel could free was cache: buff/cache fell from 371Mi to 123Mi. The guest became very slow. The recording jumps 20:05:54 → 20:06:15 and 20:06:49 → 20:07:21 (21 s and 32 s instead of 3 s), and the run took 1 min 46 s instead of 90 s. stress-ng reported `passed`: **no process was killed**, and `journalctl -k` had no OOM line.
- **Run 2, 150% with `--vm-keep` (about 20:10):** the guest froze completely. Both SSH sessions and the VM console stopped responding for more than 4 minutes, so the VM was reset (Machine → Reset). The recording of this run was not saved, most likely because the data had not been written to disk before the reset. After the reboot, `sudo journalctl -k -b -1 | grep -i -E "out of memory|oom-kill|killed process"` returned nothing.
- **Run 3, python 1.5 GB (20:19:42–20:19:45):** used jumped to 1.5Gi and available to **101Mi at 20:19:45**. That is the last line in the file: the guest froze again and was reset. `sudo journalctl -k --since "45 min ago" | grep ...` returned nothing, so the OOM killer never ran.
- **Run 4, cgroup 400 MB (20:26:04):** `Killed` after two seconds (20:26:06). The guest stayed responsive; used went 388Mi → 671Mi (20:26:06) → 418Mi (20:26:09).

```
$ date +%T; sudo systemd-run --scope -p MemoryMax=400M -p MemorySwapMax=0 python3 -c "a = b'x' * (1500 * 1024 * 1024)"; date +%T
20:26:04
Running as unit: run-p1731-i4685.scope; invocation ID: 94005c19ff314a8b8df1987986b248a0
Killed                     sudo systemd-run --scope -p MemoryMax=400M -p MemorySwapMax=0 python3 -c "a = b'x' * (1500 * 1024 * 1024)"
20:26:06
```

**Why the whole-system runs froze instead of being killed.** Without swap, anonymous memory (what stress-ng and python allocate) cannot be moved out of RAM. The only memory the kernel can free is file cache, and that includes the code of running programs. The kernel calls the OOM killer only when reclaim finds nothing at all to free. Before that point it keeps throwing out program code that is needed again a moment later and reading it back from disk: thrashing. With 1.6 GiB and no swap this went on for minutes, which is what the time gaps show. The `clocksource: Long readout interval` lines at 20:24–20:25 in the kernel log mean the clock watchdog saw 2–5 s gaps where it expected a short one. They come after the last reset, with nothing running in the guest, so most likely the host laptop itself (8 GB RAM) was short of resources at that moment and did not run the guest's vCPUs.

**Run 5, 120% with 1 GB swap (20:48:45–20:49:56).** This time the guest started swapping. Swap used went 0B → 17Mi (20:48:56) → 27Mi (20:48:59) → **294Mi (20:49:03)**, then fell back to 17Mi and 24Ki, most likely as stress-ng released and re-mapped its blocks. Available went down to 457Mi and buff/cache from 735Mi to 523Mi. The guest slowed down but did not freeze: the recording has one 14 s gap (20:48:42 → 20:48:56), the run took 1 min 11 s instead of 60 s, and stress-ng reported `passed`. No process was killed and `sudo journalctl -k --since "10 min ago" | grep ...` printed nothing. With swap the kernel could move idle anonymous pages to disk instead of throwing out program code, so it did not get stuck.

```
$ date +%T; stress-ng --vm 2 --vm-bytes 120% --vm-method flip --timeout 60s; date +%T
20:48:45
stress-ng: info:  [1776] setting to a 1 min run per stressor
stress-ng: info:  [1776] dispatching hogs: 2 vm
stress-ng: info:  [1777] vm: using 394.80MB per stressor instance (total 789.60MB of 658MB available memory)
stress-ng: info:  [1776] passed: 2: vm (2)
stress-ng: info:  [1776] failed: 0
stress-ng: info:  [1776] successful run completed in 1 min 11.15 secs
20:49:56
```

### What the kernel did

`evidence/kernel-log-extract.txt` (command on the first line):

```
Nov 15 20:26:06 Innotech kernel: python3 invoked oom-killer: gfp_mask=0xcc0(GFP_KERNEL), order=0, oom_score_adj=0
Nov 15 20:26:06 Innotech kernel: [  pid  ]   uid  tgid total_vm      rss rss_anon rss_file rss_shmem pgtables_bytes swapents oom_score_adj name
Nov 15 20:26:06 Innotech kernel: [   1731]     0  1731   388673   103848   102117     1731         0   901120        0             0 python3
Nov 15 20:26:06 Innotech kernel: oom-kill:constraint=CONSTRAINT_MEMCG,nodemask=(null),cpuset=/,mems_allowed=0,oom_memcg=/system.slice/run-p1731-i4685.scope,task_memcg=/system.slice/run-p1731-i4685.scope,task=python3,pid=1731,uid=0
Nov 15 20:26:06 Innotech kernel: Memory cgroup out of memory: Killed process 1731 (python3) total-vm:1554692kB, anon-rss:408468kB, file-rss:6924kB, shmem-rss:0kB, UID:0 pgtables:880kB oom_score_adj:0
```

- **Which process:** `python3`, PID 1731.
- **Why that one:** it was the only process in the cgroup `run-p1731-i4685.scope`, and it held all of it: `anon-rss:408468kB`, which is 399 MiB, right at the 400M limit. It had asked for about 1.5 GB (`total-vm:1554692kB`). `oom_score_adj:0` means nothing protected it.
- **When:** 20:26:06 UTC, two seconds after the start. It matches `memory-pressure.txt`: at 20:26:06 used is 671Mi, and at 20:26:09 it is back to 418Mi because the memory was freed.
- `constraint=CONSTRAINT_MEMCG` shows this is the kernel's normal OOM killer, triggered by the cgroup limit instead of the whole machine running out. That is why it worked in two seconds without freezing the guest, while runs 1–3 never reached it.

### Windows

```
PS C:\WINDOWS\system32> Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Microsoft-Windows-Resource-Exhaustion-Detector'} -MaxEvents 5 | Format-List TimeCreated, Id, Message
Get-WinEvent : No events were found that match the specified selection criteria.
At line:1 char:1
+ Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Micro ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : ObjectNotFound: (:) [Get-WinEvent], Exception
    + FullyQualifiedErrorId : NoMatchingEventsFound,Microsoft.PowerShell.Commands.GetWinEventCommand
```

No events: the Windows guest never ran low on memory. Windows does not kill processes like the Linux OOM killer. When the commit charge gets close to the commit limit (RAM plus page file), new allocations fail and the Resource-Exhaustion-Detector writes **event 2004** to the System log, "Windows successfully diagnosed a low virtual memory condition", naming the processes that used the most memory. On this guest that would need something like Sysinternals Testlimit pushing the commit charge up, which I did not run.

After the experiment the swap file was switched off and deleted, the Ubuntu guest was powered off and its RAM set back to 4096 MB. The `before-lab6` snapshot was kept but not restored, so the installed packages and `~/lab06` stay in place.

## What did not work the first time

**1. VBoxService did not exist on Ubuntu.** `pgrep -a VBoxService` printed nothing, because Guest Additions had never been installed in this guest. I installed the packaged version (`sudo apt install -y virtualbox-guest-utils`, then `sudo systemctl start virtualbox-guest-utils`). After that `pgrep` showed `/usr/sbin/VBoxService`, and it now starts on every boot.

**2. stress-ng crashed with SIGILL.** All three runs from the guide ended in 1–4 seconds without filling memory:

```
$ date +%T; stress-ng --vm 2 --vm-bytes 70% --timeout 60s; date +%T
19:59:26
stress-ng: info:  [1750] vm: using 263.60MB per stressor instance (total 527.20MB of 753.14MB available memory)
stress-ng: debug: [1752] caught SIGILL, address 0x0000591c1188ab67 (ILL_ILLOPN)
stress-ng: error: [1749] vm: [1750] terminated with an error, exit status=2 (stressor failed)
stress-ng: info:  [1749] failed: 2: vm (2)
stress-ng: info:  [1749] unsuccessful run completed in 4.25 secs
19:59:30
```

SIGILL means "illegal instruction": the default vm method executed a CPU instruction that the VirtualBox virtual CPU does not support. The bytes at the crash address start with `c5 f9 90`, which looks like an AVX-512 mask instruction, but I did not confirm which one. Choosing a plain method, `--vm-method flip`, fixed it: the next run printed `passed: 1` and `successful run completed`.

**3. Filling the whole guest froze it instead of producing an OOM line.** Runs 2 and 3 hung the guest for minutes and I had to reset it twice. Right after the second reset it hung once more with no load at all, and I reset it a third time. The first reset also lost the unsaved part of the recording. The reason is the thrashing described above. Fixes: `sync` in the recording loop so nothing is lost on a hang, and run 4 in a cgroup with a memory limit, which got the OOM killer in two seconds.

**4. Restarts changed the PIDs.** In the middle of Part 1 the laptop had to be restarted, and later the Ubuntu guest. The first Task Manager screenshot (PID 1828) belonged to a process that no longer existed, so it was retaken (PID 1876), and the Ubuntu PID changed 2351 → 1102 → 1194. In the final evidence Task Manager and Process Explorer show the same process (PID 1876) from the same Windows boot.

## Evidence

- [evidence/task-manager.png](evidence/task-manager.png) — Task Manager Details: VBoxService.exe PID 1876 with Working set, active private working set, Commit size, Handles, Threads
- [evidence/process-explorer.png](evidence/process-explorer.png) — Process Explorer: the same PID 1876 in the tree with Private Bytes, Working Set, WS Private, Handles, Threads, and its handles in the lower pane
- [evidence/process-explorer-image.png](evidence/process-explorer-image.png) — Properties → Image: parent services.exe (860), command line, user SYSTEM, start time
- [evidence/htop.png](evidence/htop.png) — htop tree on Ubuntu: VBoxService PID 1194 with VIRT, RES, SHR, CPU%, MEM% and its threads
- [evidence/memory-pressure.txt](evidence/memory-pressure.txt) — `free -h` every 3 s: before, during and after, each with a time; runs 1, 3 and 4 without swap, run 5 with 1 GB swap (swap used up to 294Mi)
- [evidence/kernel-log-extract.txt](evidence/kernel-log-extract.txt) — kernel log: the OOM killer killed python3 (PID 1731) at 20:26:06
