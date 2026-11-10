# Lab 3 — Teardown, and the same machine from the command line

Pair: Bostan Temirlan (No Pair)

Driver first half: Bostan

Machine: Host Acer Nitro AN515-57 (Windows 11), guest Innotech (Ubuntu Server, VirtualBox)

Date: 10.11.2026

## Part 1 — Ten parts

### AMD Ryzen 5 7600

![](evidence/photos/ryzen5-7600.png)

Desktop processor: 6 cores / 12 threads, 3.8 GHz base, up to 5.1 GHz boost, 6 MB L2 + 32 MB L3 cache, 65 W TDP, integrated Radeon Graphics. **Connects to** socket AM5; its memory controller is DDR5 only (two channels). **Limit:** fits only AM5 boards and cannot use DDR4; the official memory speed is DDR5-5200 with two modules.

Source: https://www.amd.com/en/products/processors/desktops/ryzen/7000-series/amd-ryzen-5-7600.html

### Intel Core i5-13400

![](evidence/photos/i5-13400.png)

Desktop processor: 10 cores (6 Performance + 4 Efficient), 16 threads, up to 4.6 GHz, 20 MB cache, 65 W base power / 148 W maximum turbo power, integrated UHD Graphics 730. **Connects to** socket LGA1700; its controller supports DDR4 up to 3200 MT/s or DDR5 up to 4800 MT/s. **Limit:** fits only LGA1700 boards; the board decides whether it runs DDR4 or DDR5, never both.

Source: https://www.intel.com/content/www/us/en/products/sku/230495/specifications.html

### ASUS PRIME B650M-A

![](evidence/photos/asus-b650m-a.png)

Micro-ATX motherboard on the AMD B650 chipset. **Connects to** an AM5 processor, 4 × DDR5 DIMM, 2 × M.2 (M.2_1 PCIe 5.0 x4 from the CPU, M.2_2 PCIe 4.0 x4 from the chipset) and 4 × SATA 6 Gb/s. **Limit:** accepts only AM5 processors (Ryzen 7000 / 8000 / 9000) and only DDR5 memory.

Source: https://asus.com/motherboards-components/motherboards/prime/prime-b650m-a/techspec

### MSI PRO B760M-A WIFI DDR4

![](evidence/photos/msi-b760m-a-ddr4.png)

Micro-ATX motherboard on the Intel B760 chipset. **Connects to** an LGA1700 processor, 4 × DDR4 DIMM (up to 128 GB), 2 × M.2 PCIe 4.0 x4 (M.2_2 also takes SATA M.2) and 4 × SATA 6 Gb/s. **Limit:** accepts only Intel 12th / 13th / 14th Gen processors and only DDR4 memory; DDR5 modules do not fit.

Source: https://www.msi.com/Motherboard/PRO-B760M-A-WIFI-DDR4/Specification

### Kingston FURY Beast DDR5-5600, 16 GB

![](evidence/photos/kingston-ddr5-5600.png)

DDR5 DIMM memory module, 16 GB, 5600 MT/s, 288 pins. **Connects to** a DDR5 DIMM slot, one module per slot. **Limit:** fits only DDR5 boards — the notch is in a different place than on DDR4; 5600 MT/s is reached only through the overclocking profile (XMP/EXPO), otherwise the module runs at a lower standard speed.

Source: https://www.kingston.com/datasheets/KF556C40BB-16.pdf

### Crucial DDR4-3200, 16 GB DIMM

![](evidence/photos/crucial-ddr4-3200.png)

DDR4 UDIMM memory module, 16 GB, 3200 MT/s, 288 pins. **Connects to** a DDR4 DIMM slot. **Limit:** fits only DDR4 boards — same pin count as DDR5, but the notch is in a different place, so it cannot be inserted into a DDR5 slot.

Source: https://crucial.in/memory/ddr4/cp16g4dfra32a

### Samsung 990 PRO 1 TB

![](evidence/photos/samsung-990-pro.png)

NVMe SSD, 1 TB, PCIe 4.0 x4 / NVMe 2.0, form factor M.2 2280, up to 7,450 MB/s read and 6,900 MB/s write. **Connects to** an M.2 PCIe slot directly on the board, no cables. **Limit:** needs a PCIe M.2 slot; full speed only on PCIe 4.0 or newer, a PCIe 3.0 slot would cut it roughly in half.

Source: https://www.samsung.com/ca/memory-storage/nvme-ssd/990-pro-1tb-nvme-pcie-gen-4-mz-v9p1t0b-am

### Samsung 870 EVO 1 TB

![](evidence/photos/samsung-870-evo.png)

SATA SSD, 1 TB, 2.5-inch, SATA 6 Gb/s, up to 560 MB/s read and 530 MB/s write. **Connects to** a SATA port on the board with a data cable, plus a SATA power cable from the power supply. **Limit:** the SATA bus itself — it tops out at about 550 MB/s, more than ten times slower than the 990 PRO.

Source: https://www.samsung.com/uk/memory-storage/sata-ssd/870-evo-1tb-sata-3-2-5-ssd-mz-77e1t0b-eu

### Corsair RM750e (750 W)

![](evidence/photos/corsair-rm750e.png)

ATX power supply, 750 W, 80 PLUS Gold, ATX 3.1, fully modular. **Connects to** the board (1 × 24-pin, 2 × EPS 8-pin for the CPU), drives (SATA power) and a graphics card (PCIe 8-pin or 12V-2x6). **Limit:** 750 W total for the whole computer.

Source: https://www.corsair.com/p/CP-9020262-EU

### Stock cooler — AMD Wraith Stealth

![](evidence/photos/wraith-stealth.png)

Air cooler that AMD lists as the in-box thermal solution of the Ryzen 5 7600. **Connects to** the AM5 socket mount and the CPU fan header of the board. **Limit:** it is sized for the 65 W processor it ships with; a hotter CPU needs a bigger cooler.

Source: https://www.amd.com/en/products/processors/desktops/ryzen/7000-series/amd-ryzen-5-7600.html

## The motherboards

| | ASUS PRIME B650M-A | MSI PRO B760M-A WIFI DDR4 |
|---|---|---|
| Socket | AM5 | LGA1700 |
| Chipset | AMD B650 | Intel B760 |
| Memory | DDR5, 4 slots | DDR4, 4 slots, max 128 GB |
| M.2 | 2 (PCIe 5.0 x4 + PCIe 4.0 x4) | 2 (PCIe 4.0 x4 each) |
| SATA | 4 × 6 Gb/s | 4 × 6 Gb/s |
| Processors accepted | Ryzen 7000 / 8000 / 9000 | Intel Core 12th / 13th / 14th Gen, Pentium Gold, Celeron |
| BIOS update needed? | TODO: CPU Support tab, row "Ryzen 5 7600" | TODO: CPU Support tab, row "i5-13400" |

## Two builds

### Build 1 — AMD

| Part | Model | Why it fits here |
|---|---|---|
| Processor | AMD Ryzen 5 7600 | AM5 processor; this is the only AM5 board in the list |
| Motherboard | ASUS PRIME B650M-A | AM5 socket, B650 supports Ryzen 7000 |
| Memory | Kingston FURY Beast DDR5-5600 16 GB | the CPU and the board take DDR5 only; the DDR4 module would not go into the slot |
| SSD | Samsung 990 PRO 1 TB | goes into M.2_1 (PCIe 5.0 x4 slot, the drive runs at its full PCIe 4.0 speed) |
| Cooler | AMD Wraith Stealth | ships in the box with this processor and mounts on AM5 |
| Power supply | Corsair RM750e | 24-pin + EPS 8-pin match the board; 750 W is far above a 65 W CPU with no graphics card |

### Build 2 — Intel

| Part | Model | Why it fits here |
|---|---|---|
| Processor | Intel Core i5-13400 | LGA1700 processor; this is the only LGA1700 board in the list |
| Motherboard | MSI PRO B760M-A WIFI DDR4 | LGA1700 socket, B760 supports 13th Gen |
| Memory | Crucial DDR4-3200 16 GB DIMM | the board has DDR4 slots only; 3200 MT/s is exactly the CPU's top DDR4 speed |
| SSD | Samsung 870 EVO 1 TB | goes to one of the four SATA 6 Gb/s ports |

### What each build still needs

- **Build 1:** a case, a monitor with keyboard and mouse, an operating system. It has everything else to switch on: the CPU has integrated graphics, so no graphics card is required.
- **Build 2:** a **power supply** — the list has one PSU for two computers; a **CPU cooler** — the list has one cooler, and Intel's specification page does not say whether one is in the box; a SATA data cable for the 870 EVO; a case, a monitor with keyboard and mouse, an operating system. No graphics card is required (UHD Graphics 730).
- Both builds have a single 16 GB module, so memory runs in single-channel mode. They work, but a second identical module would be the first upgrade.

## Part 2 — Same facts, three operating systems

| Fact | Windows (PowerShell) | Linux | macOS (not run — no Mac in the pair) |
|---|---|---|---|
| CPU model | `Get-CimInstance Win32_Processor \| Select Name` | `lscpu` (Model name) | `sysctl -n machdep.cpu.brand_string` |
| Cores / threads | `Get-CimInstance Win32_Processor \| Select NumberOfCores, NumberOfLogicalProcessors` | `lscpu` (Core(s) per socket, CPU(s)) | `sysctl hw.physicalcpu hw.logicalcpu` |
| Total memory | `Get-CimInstance Win32_PhysicalMemory` (sum of Capacity) | `free -h` | `sysctl hw.memsize` |
| Memory modules and speed | `Get-CimInstance Win32_PhysicalMemory \| Select DeviceLocator, Capacity, Speed` | `sudo dmidecode -t memory` | `system_profiler SPMemoryDataType` |
| Disk model and type | `Get-PhysicalDisk \| Select FriendlyName, MediaType, BusType, Size` | `lsblk -d -o NAME,MODEL,ROTA,TRAN,SIZE` | `diskutil info disk0` |
| Free space | `Get-Volume C` | `df -h /` | `diskutil info disk0` |
| Architecture (x86-64 / ARM64) | `$env:PROCESSOR_ARCHITECTURE` | `uname -m` | `uname -m` |

TODO (2–3 sentences, from your own output): how the names differ between the systems; what the VM showed differently from the host.

## What did not work the first time

TODO: one real thing — what you saw, what it turned out to be, what you did.

## Evidence

- [evidence/windows-specs.txt](evidence/windows-specs.txt) — raw PowerShell output on the Windows host: CPU, memory modules, disk, free space, architecture
- [evidence/linux-specs.txt](evidence/linux-specs.txt) — raw output of the same facts inside the Ubuntu guest
- [evidence/photos/](evidence/photos/) — the makers' product photos for the ten parts
