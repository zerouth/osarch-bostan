# Developer Test Machine — Rebuild Guide

**Target Audience:** Office Management / IT Onboarding (Aigerim T.)  
**Purpose:** Rebuilding isolated Linux and Windows virtual test machines from scratch without risking host stability.

---

## Prerequisites: What to Download

1. **Hypervisor (Oracle VirtualBox 7.x & Extension Pack):** Download from [virtualbox.org](https://www.virtualbox.org/). It is free for educational and evaluation use under the VirtualBox PUEL/GPL licence, so no commercial hypervisor licences need to be purchased.
2. **Ubuntu Server 26.04 LTS ISO:** Download the Server ISO from [ubuntu.com](https://ubuntu.com/). Server edition has no graphical desktop environment, saving host CPU and RAM.
3. **Windows 11 Enterprise Evaluation ISO:** Download legally from the [Microsoft Evaluation Center](https://www.microsoft.com/en-us/evalcenter/download-windows-11-enterprise). This provides a legal 90-day sandbox environment without purchasing retail product keys.

---

## Step 1. Create the Shared Network (`osarch-net`)

1. Open VirtualBox, click **File** $\rightarrow$ **Tools** $\rightarrow$ **Network Manager**.
2. Switch to the **NAT Networks** tab and click **Create**.
3. Name it `osarch-net`, set IPv4 Prefix to `10.0.2.0/24`, and check **Enable DHCP**.
4. Click **Apply**.

> **Why NAT Network and not Bridged:** The office and campus Wi-Fi networks filter traffic by MAC address, meaning a Bridged adapter gets blocked immediately. Standard NAT isolates virtual machines behind separate virtual routers where they cannot reach each other. `NAT Network` creates an internal subnet where both machines can communicate while sharing the laptop's internet connection.  
> **Check:** You should see `osarch-net` listed as active with DHCP enabled in the Network Manager table.

---

## Step 2. Create the Linux Virtual Machine (`Innotech`)

1. Click **New** in the VirtualBox top toolbar.
2. Set Name: `Innotech`, Type: `Linux`, Version: `Ubuntu (64-bit)`.
3. In Hardware settings, set Base Memory to **2048 MB (2 GB)** and Processors to **2 vCPU**.

![](evidence/01-new-vm-wizard.png)

> **Why 2 GB RAM:** Our host laptops have 8 GB of RAM total, and Windows 11 idle background processes already occupy ~7.0 GB. Allocating more than 2 GB saturates physical RAM, triggers heavy SSD paging, and freezes the host laptop completely.  
> **Check:** The configuration summary displays 2048 MB RAM and 2 vCPUs.

---

## Step 3. Configure the Linux Virtual Disk

1. In the Virtual Hard Disk screen, select **Create a Virtual Hard Disk Now**.
2. Set File size to **25.00 GB**.
3. Select **Dynamically allocated** (Thin Provisioning).
4. Click **Finish**.

![](evidence/02-disk-settings.png)

> **Why Dynamically allocated:** A fixed-size disk immediately reserves all 25 GB on the host drive, whereas dynamically allocated storage only consumes real SSD space when data is actually written.  
> **Check:** In VM Settings $\rightarrow$ Storage, the `.vdi` file lists format as "Dynamically expanding storage".

---

## Step 4. Create the Windows 11 Virtual Machine (`lab02-windows`)

1. Click **New** in VirtualBox.
2. Name: `lab02-windows`, Type: `Microsoft Windows`, Version: `Windows 11 (64-bit)`.
3. Hardware: Base Memory **2048 MB (2 GB)**, Processors: **2 vCPU**, and check **Enable EFI**.
4. In System $\rightarrow$ Security, set **TPM 2.0** to *Virtual TPM*.
5. Virtual Hard Disk: set Size to **64.00 GB**, choose **Dynamically allocated**, and click **Finish**.

> **Why EFI and TPM:** Windows 11 installer checks hardware requirements and aborts installation if UEFI boot and TPM 2.0 emulation are not enabled. We allocate 2 GB RAM instead of Microsoft's recommended 4 GB to prevent host lockups.  
> **Check:** Open Settings $\rightarrow$ System and verify that both "Enable EFI" and "TPM 2.0" are enabled.

---

## Step 5. Connect Both VMs to the Shared Network

1. For `Innotech`, click **Settings** $\rightarrow$ **Network**.
2. On Adapter 1, set Attached to: **NAT Network**.
3. In the Name field, select `osarch-net` and click **OK**.
4. Repeat this exact setting for `lab02-windows`.

![](evidence/03-network-adapter.png)

> **Why:** If one machine is left on standard NAT, it receives a separate isolated router address, preventing developer client-server testing between the two systems.  
> **Check:** Inside Ubuntu, run `ip addr`. The machine should show an IP address like `10.0.2.x` assigned by `osarch-net`.

---

## Step 6. Complete OS Installations

1. Mount the Ubuntu ISO in `Innotech` Storage settings, start the VM, and follow standard console installation prompts.
2. Mount the Windows 11 ISO in `lab02-windows`, start the VM, and complete standard setup without entering a product key (Evaluation edition).

> **Why:** Installing base operating systems without extra third-party software preserves free memory and disk space for developer tools.  
> **Check:** Both virtual machines boot cleanly to their respective login prompts.

---

## Step 7. Configure Windows Firewall for Inter-Guest Pings

1. Log into Windows 11, right-click the Start button, and select **Terminal (Admin)** or **PowerShell (Administrator)**.
2. Run this command:

```powershell
New-NetFirewallRule -DisplayName "Allow ping in (ICMPv4)" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow

```

> **Why:** Windows Defender Firewall treats the virtual network adapter as a Public profile and silently drops incoming ICMP echo requests. Turning off the firewall entirely is dangerous and violates security policy; adding this rule safely permits ping testing while keeping system security active.
> **Check:** From the Ubuntu console, run `ping 10.0.2.4`. You should receive replies with 0% packet loss.

---

## Step 8. Take a Clean Baseline Snapshot

1. Shut down both virtual machines cleanly.
2. Select `Innotech`, open the **Snapshots** panel on the right, click **Take**, and name it `clean-install`.
3. Repeat for `lab02-windows`.

> **Why:** This fulfills the requirement "without breaking anything". When the developer makes an error, modifies system files, or breaks networking, select `clean-install` and click **Restore**. The environment returns to a pristine state in under 5 seconds without reinstalling.
> **Check:** The snapshot hierarchy displays `clean-install` as a saved state.

---

## Step 9. Step-by-Step Rollback Procedure (When Developer Breaks Something)

When the developer encounters a corrupted system state, broken configuration, or OS failure, follow these exact steps to restore the clean baseline:

1. Power off the malfunctioning virtual machine completely. If the guest OS is frozen, select **Machine** $\rightarrow$ **Close** $\rightarrow$ **Power off the machine** in the VirtualBox window.
2. In the VirtualBox Manager, select the VM from the left list.
3. Open the **Snapshots** panel from the top-right menu.
4. Left-click the snapshot named `clean-install`.
5. Click the **Restore** button (circular counter-clockwise arrow icon).
6. A dialog box will appear asking: *"Do you want to create a snapshot of the current machine state?"*
**Uncheck** this option. We want to discard the broken state entirely.
7. Click **Restore**.
8. Start the VM. The guest boots immediately into its original working configuration.

---

## Step 10. Troubleshooting Common Problems

1. **Host laptop freezes or locks up completely:**
* *Cause:* More than 2 GB RAM was assigned to a VM on an 8 GB host laptop.
* *Fix:* Power off the VM, open Settings $\rightarrow$ System, and set Base Memory strictly back to 2048 MB.


2. **Guests cannot ping each other:**
* *Cause:* An adapter was left on standard NAT instead of NAT Network, or the Windows firewall rule was skipped.
* *Fix:* Ensure both VMs use `osarch-net` (Step 5) and re-run the PowerShell firewall command in Windows (Step 7).



```
