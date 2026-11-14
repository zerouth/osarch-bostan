# Lab 4 — Partition, mirror, fail, recover

Pair: Bostan Temirlan (No Pair) · Date: 15.11.2026 · Hypervisor: VirtualBox

Machine: Host Acer Nitro AN515-57 (Windows 11), guests: VM "Windows" (Windows 11, from Lab 2) and VM "Ubuntu" (Ubuntu Server, from Lab 1). New disks: `lab04-win` (1 GB) for Windows, `lab04-d1`, `lab04-d2`, `lab04-d3` (1 GB each, dynamically allocated, same SATA controller as the system disk) for Ubuntu.

## Windows

```powershell
Initialize-Disk -Number 1 -PartitionStyle GPT
New-Partition -DiskNumber 1 -UseMaximumSize -AssignDriveLetter |
    Format-Volume -FileSystem NTFS -NewFileSystemLabel LAB04
```

```
$ Get-Disk | Select Number, FriendlyName, PartitionStyle, Size

Number FriendlyName  PartitionStyle        Size
------ ------------  --------------        ----
     0 VBOX HARDDISK GPT            85899345920
     1 VBOX HARDDISK GPT             1073741824

$ Get-Volume | Where FileSystemLabel -eq 'LAB04'

DriveLetter FriendlyName FileSystemType DriveType HealthStatus OperationalStatus SizeRemaining       Size
----------- ------------ -------------- --------- ------------ ----------------- -------------       ----
E           LAB04        NTFS           Fixed     Healthy      OK                    989.98 MB 1007.93 MB
```

Disk 1 was RAW before `Initialize-Disk`; now it is GPT with one NTFS partition labelled LAB04 on drive E:.

**MBR or GPT:** GPT. Windows 11 boots through UEFI, which uses GPT, and GPT keeps a backup copy of the partition table at the end of the disk with CRC32 checksums, so a damaged table can be detected and restored; MBR has no backup and is limited to 2 TiB and four primary partitions, which gives no advantage here.

## Linux — layout before and after

### Before

```
$ lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS
NAME    SIZE TYPE FSTYPE   MOUNTPOINTS
loop0  66.8M loop squashfs /snap/core24/1643
loop1   1.5M loop squashfs /snap/hwctl/131
loop2   1.5M loop squashfs /snap/hwctl/123
loop3  50.1M loop squashfs /snap/snapd/27710
sda      25G disk
├─sda1    1M part
└─sda2   25G part ext4     /
sdb       1G disk
sdc       1G disk
sdd       1G disk
sr0    50.7M rom  iso9660
```

### After

```
$ lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS
NAME     SIZE TYPE  FSTYPE            MOUNTPOINTS
loop0   66.8M loop  squashfs          /snap/core24/1643
loop1    1.5M loop  squashfs          /snap/hwctl/131
loop2    1.5M loop  squashfs          /snap/hwctl/123
loop3   50.1M loop  squashfs          /snap/snapd/27710
sda       25G disk
├─sda1     1M part
└─sda2    25G part  ext4              /
sdb        1G disk
└─sdb1  1022M part  linux_raid_member
  └─md0 1021M raid1 ext4              /mnt/mirror
sdc        1G disk
└─sdc1  1022M part  linux_raid_member
sdd        1G disk
└─sdd1  1022M part  linux_raid_member
  └─md0 1021M raid1 ext4              /mnt/mirror
sr0     50.7M rom   iso9660
```

`md0` now sits on `sdb1` and `sdd1` and is mounted on `/mnt/mirror`. `sdc1` still shows `linux_raid_member` because the old RAID superblock stays on the partition after `--remove`, but it is no longer part of the array (see `array-rebuilt.txt`). The array is saved in `/etc/mdadm/mdadm.conf`:

```
$ sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
ARRAY /dev/md0 metadata=1.2 UUID=93009518:19a94964:0c74e668:42bfbd9e
$ sudo update-initramfs -u
update-initramfs: Generating /boot/initrd.img-7.0.0-38-generic
```

## What I did

Create (one GPT partition per disk with the RAID flag, then a RAID 1 from two of them):

```bash
for d in sdb sdc sdd; do
  sudo parted -s /dev/$d mklabel gpt mkpart primary 1MiB 100% set 1 raid on
done
sudo apt install -y mdadm
sudo mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1
#   "enable write-intent bitmap?" -> y ; "Continue creating array?" -> y
cat /proc/mdstat
sudo mkfs.ext4 -L mirror /dev/md0
sudo mkdir -p /mnt/mirror
sudo mount /dev/md0 /mnt/mirror
sudo chown $USER: /mnt/mirror
echo "Lab 4 proof file — Bostan Temirlan — $(date)" > /mnt/mirror/proof.txt
head -c 20M /dev/urandom > /mnt/mirror/random.bin
```

Fail (`--fail` used, not a detached disk):

```bash
sudo mdadm /dev/md0 --fail /dev/sdc1
sudo mdadm /dev/md0 --remove /dev/sdc1
cat /mnt/mirror/proof.txt
diff <(tail -n +2 evidence/checksum-before.txt) <(tail -n +2 evidence/checksum-after-failure.txt) && echo "checksums match"
```

Rebuild:

```bash
sudo mdadm /dev/md0 --add /dev/sdd1
cat /proc/mdstat
sudo mdadm --detail --scan | sudo tee -a /etc/mdadm/mdadm.conf
sudo update-initramfs -u
```

## Three states

| State | What /proc/mdstat showed | File |
| --- | --- | --- |
| Healthy | [2/2] [UU] | evidence/array-healthy.txt |
| Degraded | [2/1] [U_] | evidence/array-degraded.txt |
| Rebuilt | [2/2] [UU], sdd1 replaced sdc1 | evidence/array-rebuilt.txt |

Checksums before and after the failure: **match** (`proof.txt` a5e5aae1…, `random.bin` 5a3ac548… in both files; `diff` printed `checksums match`). The degraded array, running on `sdb1` alone, still served both files unchanged.

## RAID is not a backup

Your colleague deleted the wrong file from the mirror an hour ago. Does RAID 1 help? Why?

No. RAID 1 writes every change to both disks at the same moment, so the deletion was copied to the second disk instantly and the file is gone from both. RAID protects against a disk dying (availability), not against human mistakes, malware or corruption — it mirrors those too; only a separate copy made before the mistake, a backup or a snapshot, can bring the file back.

## What did not work the first time

**What I saw:** while `sudo apt install -y mdadm` was still running I started typing the next command and pressed Ctrl+Z instead of waiting. The shell printed `[1]+  Stopped  sudo apt install -y mdadm`. The mdadm binary was already unpacked, so `mdadm --create` still worked, but apt stayed frozen in the background. After `fg` it hung for about 10 minutes with no output.

**What it was:** Ctrl+Z does not stop a program, it suspends it (SIGTSTP) as a background job. The suspended apt kept the dpkg lock, and after `fg` it was waiting at the needrestart "Scanning processes" step, which the terminal did not redraw.

**What I did:** interrupted it properly with Ctrl+C, then finished the package setup and checked the result:

```bash
sudo dpkg --configure -a
jobs                 # empty: no stopped jobs left
mdadm --version      # mdadm - v4.5 - 2025-12-16 - Ubuntu 4.5-5ubuntu1.1
cat /proc/mdstat     # md0 still [2/2] [UU]
```

Lesson: wait for the prompt before typing the next command; Ctrl+C cancels, Ctrl+Z only pauses.

## Evidence

- [evidence/lsblk-before.txt](evidence/lsblk-before.txt) — three empty 1 GB disks next to the system disk, before any change
- [evidence/array-healthy.txt](evidence/array-healthy.txt) — md0 `[2/2] [UU]`, `State : clean`, sdb1 + sdc1 active sync
- [evidence/checksum-before.txt](evidence/checksum-before.txt) — SHA-256 of proof.txt and random.bin before the failure
- [evidence/array-degraded.txt](evidence/array-degraded.txt) — md0 `[2/1] [U_]`, `State : clean, degraded` after sdc1 was failed and removed
- [evidence/checksum-after-failure.txt](evidence/checksum-after-failure.txt) — the same SHA-256 sums on the degraded array: data survived
- [evidence/array-rebuilt.txt](evidence/array-rebuilt.txt) — md0 `[2/2] [UU]` again, sdd1 instead of sdc1
