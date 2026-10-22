# Lab 0 — Inventory your own machine

Pair: Bostan Temirlan / None

Machine: Acer Nitro AN515-57

Date: 22.10.2026 (New Try).

## What I did

Used PowerShell to collect hardware information.

`Get-CimInstance Win32_Processor | Select-Object Name, NumberOfCores, NumberOfLogicalProcessors`
`Get-CimInstance Win32_PhysicalMemory`
`Get-PhysicalDisk`
`Get-Volume`
`Get-ComputerInfo`

## Result

| What | Value | Where I got it |
|---|---|---|
| CPU model, cores, threads | 11th Gen Intel(R) Core(TM) i5-11400H @ 2.70GHz, 6 cores, 12 threads | `Get-CimInstance Win32_Processor \| Select-Object Name, NumberOfCores, NumberOfLogicalProcessors` |
| Total memory, modules, speed | 8 GB total, 1 module, 3200 MHz | `Get-CimInstance Win32_PhysicalMemory` |
| Disk model, type, free space | NVMe WDC PC SN530 (SSD), 102.53 GB free on C: | `Get-PhysicalDisk` and `Get-Volume` |
| Firmware (BIOS/UEFI), version, date | UEFI, version V1.22, date 15.07.2026 | `Get-ComputerInfo` |
| Hardware virtualization enabled? | Yes | `Get-ComputerInfo` |

## What did not work the first time

I initially tried to use the "systeminfo" command, but it could not provide the CPU core count, memory modules, disk model, and free space. I had to use specific WMI/CIM commands like Win32_Processor and Get-PhysicalDisk to get the accepted values.

I also noticed that `cpu.txt` showed `VirtualizationFirmwareEnabled False` even though virtualization is enabled. This happens because Windows reports it as False when Hyper-V is already running. I confirmed it is actually on because my `system.txt` output shows `HyperVisorPresent True`.

## Evidence

- [evidence/cpu.txt](evidence/cpu.txt) — proves CPU model, core and thread count
- [evidence/memory.txt](evidence/memory.txt) — proves memory capacity, module count, and speed
- [evidence/disk.txt](evidence/disk.txt) — proves disk model, SSD type, and remaining free space
- [evidence/system.txt](evidence/system.txt) — proves BIOS version, UEFI type, and virtualization status
