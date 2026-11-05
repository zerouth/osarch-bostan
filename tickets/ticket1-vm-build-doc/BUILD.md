# Developer Test Machine — Rebuild Guide

**Target Audience:** Office Management / IT Onboarding Support

**Goal:** Step-by-step procedure to rebuild isolated Linux and Windows 11 virtual test machines from scratch with shared networking and instant rollback.

---

## Prerequisites: Free & Legal Downloads

1. **Oracle VirtualBox 7.x & Extension Pack:** Download from [virtualbox.org](https://www.virtualbox.org/). VirtualBox is open-source under GPLv2; the Extension Pack is free for evaluation and personal use under the PUEL license.
2. **Ubuntu Server 26.04 LTS (or 24.04 LTS) ISO:** Download the official Server install image from [ubuntu.com](https://ubuntu.com/download/server). The Server edition operates in headless/console mode with zero graphical overhead, preserving host system memory.
3. **Windows 11 Enterprise Evaluation ISO:** Download legally from the [Microsoft Evaluation Center](https://www.microsoft.com/en-us/evalcenter/download-windows-11-enterprise). This provides a legal, zero-cost 90-day sandbox without purchasing commercial license keys.

---

## Step 1. Configure the Shared Network (`osarch-net`)

1. Open VirtualBox, navigate to the top menu and select **File** -> **Tools** -> **Network Manager**.
2. Switch to the **NAT Networks** tab and click the **Create** button.
3. Select the newly created network entry and configure the parameters:
* **Network Name:** `osarch-net`
* **IPv4 Prefix:** `10.0.2.0/24`
* **Enable DHCP:** Ensure this checkbox is checked.
* **Enable IPv6:** Unchecked.


4. Click **Apply** to save the network configuration.

> **Why NAT Network and not Bridged or standard NAT:**
> Standard NAT isolates each virtual machine behind its own private routing table, preventing the two guests from communicating with each other. Bridged mode assigns the guest a virtual MAC address directly on the local physical network; campus and enterprise Wi-Fi routers block unregistered MAC addresses via port security and 802.1X filtering. `NAT Network` creates a private virtual switch where both virtual machines receive internal IP addresses in the same subnet (`10.0.2.x`), can ping each other, and share the host computer's single network identity for outbound internet access.
> **Check:** In the Network Manager window, verify that `osarch-net` is listed as active with DHCP enabled.

---

## Step 2. Create the Linux Virtual Machine (`Innotech`)

1. In VirtualBox Manager, click **Machine** -> **New**.
2. Configure initial details:
* **Name:** `Innotech`
* **Type:** `Linux`
* **Version:** `Ubuntu (64-bit)`
* Check **Skip Unattended Installation** to ensure manual control over partitioning and users.


3. In the **Hardware** screen:
* **Base Memory:** Set to **2048 MB (2 GB)**.
* **Processors:** Set to **2 vCPU**.
* Leave EFI unchecked.


4. In the **Virtual Hard disk** screen:
* Select **Create a Virtual Hard Disk Now**.
* **Disk Size:** Set to **25.00 GB**.
* **Disk file type:** `VDI (VirtualBox Disk Image)`.
* **Storage allocation:** Select **Dynamically allocated** (Thin Provisioning).


5. Click **Finish**.

> **Why 2 GB RAM and Dynamically Allocated Disk:**
> Our host workstations have 8 GB of physical RAM, and Windows 11 consumes approximately 4.5 to 5.5 GB at idle. Allocating more than 2 GB to a virtual machine leaves less than 1 GB for the host OS, resulting in host kernel strain, disk swapping, and severe UI lockups. A dynamically allocated disk consumes only the actual written data size on the physical SSD (starting at a few megabytes) rather than locking 25 GB of physical storage immediately.
> **Check:**

---

## Step 3. Install Ubuntu Server OS

1. Select `Innotech`, click **Settings** -> **Storage**. Under Controller: IDE/SATA, click the optical disc icon and select the downloaded Ubuntu Server ISO. Click **OK**.
2. Click **Start** to boot the virtual machine.
3. Select **Try or Install Ubuntu Server** and press Enter.
4. **Language & Keyboard:** Select **English**, and choose the default `English (US)` layout.
5. **Install Type:** Select **Ubuntu Server (minimized)** to minimize background memory consumption.
6. **Network Connections:** Verify that interface `enp0s3` obtains an automatic IP address via DHCP (`10.0.2.x`).
7. **Proxy & Mirror:** Leave Proxy blank; accept the default Ubuntu archive mirror address.
8. **Guided Storage Configuration:** Select **Use an entire disk (25 GB)**. Uncheck "Set up this disk as an LVM group" to simplify partition structures. Select **Done** and confirm destructive writing to disk.
9. **Profile Setup:**
* **Your name:** `Bostan`
* **Your server's name:** `Innotech`
* **Pick a username:** `bostan`
* **Choose a password:** Enter a secure password and confirm.


10. **SSH Setup:** Check the box **[X] Install OpenSSH server** (mandatory for administrative access).
11. **Featured Server Snaps:** Do not select any additional packages; choose **Done**.
12. Wait for the package installation and security updates to complete, select **Reboot Now**, and press Enter when prompted to unmount the ISO.

> **Check:** Log into the console with username `bostan` and verify the kernel and release data:
> ```bash
> uname -a
> lsb_release -a
> 
> ```
> 
> 
> Output matches the records in `evidence/04-guest-uname.txt`.

---

## Step 4. Create the Windows 11 Guest (`lab02-windows`)

1. In VirtualBox Manager, click **Machine** -> **New**.
2. Configure basic parameters:
* **Name:** `lab02-windows`
* **Type:** `Microsoft Windows`
* **Version:** `Windows 11 (64-bit)`
* Check **Skip Unattended Installation**.


3. In the **Hardware** screen:
* **Base Memory:** Set strictly to **2048 MB (2 GB)**.
* **Processors:** Set strictly to **2 vCPU**.
* Check the box **[X] Enable EFI (special OSes only)**.


4. In the System settings validation:
* Ensure **TPM Type** is configured to **Virtual TPM v2.0**.


5. In the **Virtual Hard disk** screen:
* Select **Create a Virtual Hard Disk Now**.
* **Disk Size:** Set to **64.00 GB**.
* **Storage allocation:** Select **Dynamically allocated**.


6. Click **Finish**.

> **Why EFI, Virtual TPM, and 2 GB RAM:**
> The Windows 11 setup subsystem strictly enforces hardware requirements: UEFI boot flags and a physical or virtual TPM 2.0 module. Without checking EFI and Virtual TPM, the installer halts with an unsupported hardware error. While Microsoft officially recommends 4 GB of RAM, we intentionally configure 2 GB to ensure host machine stability during simultaneous guest operation.

---

## Step 5. Install Windows 11 Enterprise Evaluation

1. Select `lab02-windows`, go to **Settings** -> **Storage**, and attach the Windows 11 Enterprise Evaluation ISO to the virtual optical drive.
2. Click **Start**. When the prompt `Press any key to boot from CD or DVD...` appears, press any key immediately.
3. **Regional Settings:** Select English (United States), standard currency, and keyboard layout. Click **Next** -> **Install Now**.
4. **License Agreement:** Review and check **I accept the Microsoft Software License Terms**. Click **Next**.
5. **Setup Type:** Select **Custom: Install Windows only (advanced)**.
6. **Drive Selection:** Select `Drive 0 Unallocated Space (64.0 GB)` and click **Next** without manually partitioning; Windows will automatically generate EFI, MSR, and primary NTFS partitions.
7. Wait for file extraction and automatic system reboots.
8. **Out-of-Box Experience (OOBE):**
* Select your Region and keyboard layout.
* Enter PC name: `lab02-windows`.
* Setup choice: Select **Set up for work or school** -> **Sign-in options** -> **Domain join instead** (or create local administrator).
* Enter user account name `developer` and set a password.
* On the Privacy settings screen, toggle all diagnostic telemetry sliders to **No / Off** to minimize background CPU usage on our 2 vCPU allocation.



---

## Step 6. Attach Both VMs to `osarch-net`

1. Power off both virtual machines cleanly before altering network hardware.
2. Select `Innotech`, click **Settings** -> **Network** -> **Adapter 1**:
* **Enable Network Adapter:** Checked.
* **Attached to:** Select **NAT Network**.
* **Name:** Select `osarch-net`.
* Click **OK**.


3. Select `lab02-windows`, click **Settings** -> **Network** -> **Adapter 1**:
* **Enable Network Adapter:** Checked.
* **Attached to:** Select **NAT Network**.
* **Name:** Select `osarch-net`.
* Click **OK**.



> **Why:** Both machines must point to the identical named NAT Network switch to reside on the same broadcast domain and obtain matching `10.0.2.x` leases.
> **Check:**

---

## Step 7. Open Windows Firewall for Connection Tests

1. Power on `lab02-windows` and log into the desktop.
2. Right-click the Start Menu icon and select **Terminal (Admin)** or **PowerShell (Administrator)**.
3. Execute the following command to allow ICMPv4 ping packets:
```powershell
New-NetFirewallRule -DisplayName "Allow ping in (ICMPv4)" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow

```


4. Verify the rule status returns `Enabled : True` in the PowerShell output.

> **Why:**
> By default, Windows Defender Firewall classifies the NAT Network adapter under the Public profile and drops all unsolicited inbound ICMP Echo requests (ping). Completely disabling the firewall is a severe security violation. Creating a targeted rule allows diagnostic ICMP echo packets while keeping all other ports defended.
> **Check:** Power on `Innotech`. From the Linux terminal, run:
> ```bash
> ping -c 4 10.0.2.4
> ping -c 4 8.8.8.8
> 
> ```
> 
> 
> Both internal guest pinging and WAN connectivity must show 0% packet loss, as verified in `evidence/05-ping-between-guests.txt`.

---

## Step 8. Take a Clean Baseline Snapshot

1. Perform a clean shutdown of both virtual machines (`sudo poweroff` in Ubuntu; Start -> Shut down in Windows).
2. In the VirtualBox Manager main window:
* Select `Innotech`, click the hamburger/menu icon next to the machine name, and select **Snapshots**.
* Click the **Take** button (camera icon).
* **Snapshot Name:** `clean-install`
* **Snapshot Description:** `Base installation with working osarch-net connectivity and SSH enabled.`
* Click **OK**.


3. Repeat the exact same sequence for `lab02-windows`:
* Open its **Snapshots** menu, click **Take**, name it `clean-install`, and save.



> **Why:**
> This fulfills the mandate to let the developer test "without breaking anything". Any destructive change to packages, system files, or networking can be reverted to this verified state in seconds.
> **Check:**

---

## Step 9. Step-by-Step Rollback Procedure

When the developer encounters a corrupted system state, broken configuration, or OS failure, follow these exact steps to restore the clean baseline:

1. Power off the malfunctioning virtual machine completely. If the guest OS is unresponsive, select **Machine** -> **Close** -> **Power off the machine** in the VirtualBox window.
2. In the VirtualBox Manager, select the VM from the left panel.
3. Open the **Snapshots** panel from the top-right menu.
4. Left-click the snapshot named `clean-install`.
5. Click the **Restore** button (circular counter-clockwise arrow icon).
6. A dialog box will appear asking: *"Do you want to create a snapshot of the current machine state?"*
**Uncheck** this option. We want to discard the broken state entirely.
7. Click **Restore**.
8. Start the VM. The guest boots immediately into its original working configuration.

---

## Step 10. Troubleshooting & Common Pitfalls

### Issue 1: Windows 11 Installer halts with "This PC can't run Windows 11"

* **Root Cause:** The virtual machine was created without UEFI firmware enabled or the virtual TPM 2.0 module was omitted.
* **Resolution:**
1. Close the Windows installer window and power off the VM.
2. Open **Settings** -> **System** -> **Motherboard** tab.
3. Verify that **Enable EFI (special OSes only)** is checked.
4. Switch to the **Security** tab (or check the TPM setting in System) and ensure **TPM Type** is set to **Virtual TPM v2.0**.
5. Restart the VM and restart installation.



### Issue 2: Ping between guests times out ("Destination Host Unreachable" or 100% packet loss)

* **Root Cause:** Either one of the virtual machines is attached to standard "NAT" instead of "NAT Network (`osarch-net`)", or the Windows Defender Firewall ICMP rule was not applied.
* **Resolution:**
1. Open **Settings** -> **Network** on both VMs and verify that the adapter is explicitly set to **NAT Network** with the name matching `osarch-net`.
2. If network adapter settings are correct, open PowerShell as Administrator in Windows 11 and re-run:
```powershell
New-NetFirewallRule -DisplayName "Allow ping in (ICMPv4)" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow

```


3. Re-test ping connectivity from Ubuntu using `ping -c 4 10.0.2.4`.
