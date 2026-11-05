# Developer Test Machine — Rebuild Guide

**Target Audience:** Office Management / IT Onboarding  
**Goal:** Step-by-step guide to rebuild isolated Linux and Windows virtual test machines from scratch.

## Prerequisites: Free & Legal Downloads
1. **VirtualBox 7.x:** Download from virtualbox.org. It is free and legally approved.
2. **Ubuntu Server ISO:** Download the Server edition from ubuntu.com.
3. **Windows 11 Enterprise Evaluation ISO:** Download legally from the Microsoft Evaluation Center (free 90-day trial).

## Step 1. Configure the Shared Network
1. Open VirtualBox, click **File** -> **Tools** -> **Network Manager**.
2. Go to **NAT Networks**, click **Create**. Name it `osarch-net` and click **Apply**.
> *Why NAT Network:* Bridged mode fails on campus Wi-Fi due to security filtering. NAT Network creates an isolated, safe subnet where both VMs can communicate and reach the internet.

## Step 2. Create the Linux Guest (Backend)
1. Click **New**. Name: `Innotech`, Type: `Linux`, Version: `Ubuntu (64-bit)`.
2. Hardware: Set Base Memory to **2048 MB** and Processors to **2 vCPU**.
3. Disk: Select **Create a Virtual Hard Disk Now**, Size: **25.00 GB**, Type: **Dynamically allocated**.
4. Installation: Insert the Ubuntu ISO into Storage. Start the VM. Select "English", choose default keyboard, select "Ubuntu Server (minimized)", set username to `bostan`, check "Install OpenSSH server", and wait for the installation to finish and reboot.
> *Why 2 GB / Dynamic Disk:* Our laptops have 8 GB RAM and use ~5.8 GB at idle. Giving the VM more than 2 GB will crash the laptop. A dynamic disk prevents wasting SSD storage.

## Step 3. Create the Windows 11 Guest (Tools)
1. Click **New**. Name: `lab02-windows`, Version: `Windows 11 (64-bit)`.
2. Hardware: **2048 MB** RAM, **2 vCPU**. **Check "Enable EFI"**.
3. Security: Ensure **TPM 2.0** is set to *Virtual TPM*.
4. Disk: Size **64.00 GB**, **Dynamically allocated**.
5. Installation: Mount the Windows ISO. Start the VM. Press any key to boot from CD. Select "I don't have a product key", choose "Windows 11 Enterprise Evaluation", accept the terms, select "Custom: Install Windows only", and let the installer complete the setup.
> *Why EFI/TPM:* Windows 11 strictly requires modern boot security. We must enable these in VirtualBox or the installer will fail.

## Step 4. Connect and Test
1. For both VMs, go to **Settings** -> **Network** -> **Adapter 1**.
2. Select **Attached to: NAT Network** and choose `osarch-net`.
3. Start Windows, open PowerShell as Administrator, and run this command to allow connectivity:
`New-NetFirewallRule -DisplayName "Allow ping in (ICMPv4)" -Protocol ICMPv4 -IcmpType 8 -Direction Inbound -Action Allow`

## Step 5. Create Rollback Snapshots (Crucial)
To ensure the developer can safely test without permanently breaking the machines:
1. Turn off both virtual machines cleanly.
2. In VirtualBox, click the list icon next to each VM name and select **Snapshots**.
3. Click **Take**. Name it `clean-install` and click OK.
> *How to rollback:* If the developer breaks the OS, open this Snapshots menu, click `clean-install`, and click **Restore**. The machine will instantly revert to its perfect initial state.
