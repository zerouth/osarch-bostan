# Ticket 2 — The four builds

All prices are from one vendor, **Shop.kz (TOO «Белый Ветер KZ»)**, which delivers across Kazakhstan, taken on **16.11.2026**. Every row with its link is in [budget.csv](budget.csv); every price has a screenshot in [evidence/vendor-quotes/](evidence/vendor-quotes/).

## What decided the platform

Memory is the most expensive part of these machines right now. On 16.11.2026 at Shop.kz:

| | DDR4 (AM4) | DDR5 (AM5) |
| --- | --- | --- |
| 16 GB | 72,990 KZT (1x16 GB, 3200 MHz) | 122,990 KZT (1x16 GB, 5200 MHz) |
| 32 GB | 139,990 KZT (2x16 GB kit) | 245,980 KZT (2 sticks of 16 GB) |

DDR5 costs about **1.7 times** as much as DDR4 for the same size. 32 GB of DDR5 costs more than the processor and the motherboard together (245,980 vs 162,980 KZT). So the platform is chosen per role, not "the same four machines":

- **Accountant and sales → AM4 + DDR4.** Office software does not need a new CPU generation. The money saved on the platform pays for the memory and the screen, which is where these two jobs actually run out.
- **Web developer and designer → AM5 + DDR5.** These two will need more memory and a faster CPU in two or three years. AM5 takes newer Ryzen CPUs on the same board, and the MSI PRO B650M-P has 4 memory slots, so both can grow without a new machine.

Common to all four: a 1 TB NVMe SSD, at least 16 GB of memory, the same case (Lian Li A3-mATX), the same CPU cooler (DeepCool AK400), the same keyboard and mouse (Logitech MK120). One case and one cooler model means one set of spare parts and one assembly routine. The AK400 is 155–156 mm tall and supports both AM4 and AM5 (the Shop.kz page lists only AM4 among AMD sockets, so I checked the maker's specification); the A3-mATX takes coolers up to 165 mm.

Compatibility was checked on PCPartPicker (links in [evidence/pcpartpicker-links.md](evidence/pcpartpicker-links.md)): CPU socket ↔ board socket, board memory type ↔ memory, M.2 slot ↔ NVMe SSD, total power ↔ power supply. PCPartPicker does not price in tenge; it was used only for compatibility and power. Estimated power: 159 W, 174 W, 170 W and 315 W, against 550 / 550 / 550 / 650 W supplies. Its notes (BIOS version for the A520 board, an adapter for the case's front USB-C on that board, the AM5 bracket for the cooler) and what I did about them are in the same file.

---

### Build 1 — Accountant

**Load:** 1C:Accounting, Excel with large reports, a bank client and the tax portal (cabinet.salyk.kz) in a browser, 8+ hours a day, mostly two or three programs at once. The whole company's books live on this machine.
**Bottleneck:** not CPU or graphics. 1C and Excel are light for a 6-core CPU. What actually fails first is **the person and the data**: eight hours a day in front of one screen, and a 1C database that can be corrupted if the power cuts out in the middle of a write.
**Trade-off:** a modest AM4 platform (Ryzen 5 PRO 5650G with built-in graphics, 16 GB DDR4 as **one** stick) instead of AM5. The money went into a height-adjustable iiyama monitor (74,990 KZT instead of 49,990 for a basic one), a PCIe 4.0 SSD from a known brand, and a **UPS** (34,700 KZT) so a power cut gives time to save and shut down. One 16 GB stick runs the memory in single channel, which slows the built-in graphics a little; for spreadsheets that does not matter, and the second slot stays free for an upgrade to 32 GB. **Alternative not taken:** AM5 with Ryzen 5 8500G, which would cost about 58,000 KZT more (8500G + B650 board + 16 GB DDR5 = 248,970 KZT vs 190,570 KZT) for the same work.
**OS:** Windows 11 Pro — 1C configurations and bank clients used in Kazakhstan are set up for Windows in practice; Pro adds BitLocker to encrypt the accounting data.
**Total:** **578,400 KZT** (budget.csv, rows 2–12)

### Build 2 — Sales manager

**Load:** a CRM in the browser with 30–40 tabs, Excel, messengers, and about four hours of video calls a day with customers, often all at once.
**Bottleneck:** **memory**. Chrome with forty tabs plus a video call uses around 11–12 GB, and Windows itself needs a few more; on 16 GB that leaves almost nothing free, so one more window or a shared screen pushes the machine into swapping in the middle of a customer call. The CPU is mostly idle in this role.
**Trade-off:** the same cheap AM4 platform as the accountant, but **32 GB** of memory. On DDR4 that costs 139,990 KZT; the same 32 GB in DDR5 would cost 245,980. A basic 24" Samsung monitor (49,990 instead of 74,990) and a cheaper PCIe 3.0 SSD — copying files fast does not matter for this job. A **webcam** (20,890 KZT) was added: a desktop has no camera or microphone, and the request forgot that four hours of video calls need one. **Alternative not taken:** 16 GB and a better monitor — the screen does not help when the browser freezes during a call.
**OS:** Windows 11 Pro — same office software and management as the accountant.
**Total:** **584,590 KZT** (budget.csv, rows 14–24)

### Build 3 — Web developer

**Load:** an IDE (VS Code), Docker with 4–6 containers (app, database, cache), sometimes a virtual machine, two or three browsers for testing, a local database — all running together for a whole working day.
**Bottleneck:** **memory first, then CPU cores.** Each container and VM keeps its memory; 16 GB runs out as soon as a VM starts. Builds and containers then load all cores.
**Trade-off:** 8-core Ryzen 7 7700 and **32 GB DDR5** (the most expensive part of this machine). Saved on: no graphics card (the 7700 has built-in graphics, enough for code), the cheaper PCIe 3.0 SSD, and **no Windows licence** — Ubuntu 26.04 LTS is free and licensed under the GPL, and it is the system the company's servers most likely run, so containers behave the same as in production. **Alternative not taken:** 64 GB from day one — the board has two free slots, so 32 GB more can be added when it is needed (see question 1).
**OS:** Ubuntu 26.04 LTS (0 KZT).
**Total:** **637,100 KZT** (budget.csv, rows 26–35)

### Build 4 — Designer

**Load:** Photoshop/Illustrator/Figma with large layered files, some video for social media, colour work that must look the same in print and on customers' screens, 8 hours a day.
**Bottleneck:** **the screen and the graphics card.** Wrong colours on the monitor make the work wrong no matter how fast the PC is. Adobe apps use the GPU for filters, scaling and video export, so built-in graphics would be the next limit. Large layered files then need memory.
**Trade-off:** the most expensive machine: a 4K 27" Xiaomi A27Ui (100% sRGB, 95% DCI-P3, factory-calibrated, average ΔE < 1 according to Xiaomi) and an RTX 5060 8 GB. 32 GB DDR5, a 650 W power supply for the graphics card. Saved on: a mid-range GPU instead of an RTX 5060 Ti 16 GB (about 150,000 KZT more), and a calibrated consumer monitor instead of an ASUS ProArt (cheapest ProArt at Shop.kz: 359,990 KZT). **Alternative not taken:** a 2 TB SSD — 1 TB is the requirement, and old projects can go to a network drive (see question 3).
**OS:** Windows 11 Pro — Adobe software runs on Windows or macOS, not Linux.
**Total:** **1,143,680 KZT** (budget.csv, rows 37–47)

---

**Grand total: 2,943,770 KZT** of 3,000,000. **Reserve: 56,230 KZT** (about 2%) for price changes before the order is placed — memory and SSD prices in Kazakhstan move noticeably within a month.
