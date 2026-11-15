# Ticket 2 — Kitting out the new office

Student: Bostan Temirlan (individual work) · Date: 16.11.2026 · Prices: Shop.kz (TOO «Белый Ветер KZ»), 16.11.2026

## 1. What was asked

> **From:** Daniyar K. (Director)
> **Subject:** computers for the new office
>
> We are opening the second office and need four computers — accountant, sales, web developer, designer. Budget 3,000,000 tenge for everything. Everyone says we should just buy the same four machines, is that right? Make sure they last a few years. Monitors included.

## 2. What was actually needed

**Four identical machines is wrong.** The four people do four different jobs, and each job runs out of a different resource first:

- the **accountant** runs 1C and Excel all day: the CPU idles; what matters is the screen, and data that survives a power cut;
- **sales** keeps 30–40 browser tabs and a video call open: memory runs out first;
- the **web developer** runs containers, a VM and a database at once: memory, then CPU cores;
- the **designer** needs correct colours and GPU acceleration: the monitor and the graphics card.

One identical machine would either be too expensive for the accountant (a graphics card nobody in that job uses) or too weak for the designer and developer. With 3,000,000 KZT for everything, four copies of a machine good enough for the designer do not fit: the designer's machine alone is 1,143,680 KZT. Different machines let the money go where each job needs it. The one thing worth keeping identical is the *parts that do not decide performance* — same case, cooler, keyboard and mouse, the same vendor — so repairs and spares stay simple.

**What the request left out:**

- **"Monitors included"** — but not the rest: an **operating system licence** for each machine (Windows 11 Pro costs 102,990 KZT, about 3.4% of the budget per machine), **keyboard and mouse**, a **webcam** for the person doing four hours of video calls (a desktop has none), and a **UPS** for the accountant's 1C database.
- **What "a few years" means.** I read it as 4–5 years. That decides the platform: the developer and designer get AM5 boards that take newer CPUs and more memory later.
- **Which software each person uses** — 1C and bank clients in practice need Windows; Adobe needs Windows; a web developer can work on Linux.
- **Assembly, delivery and office furniture/network** are not mentioned; I assumed assembly is done by us and the network already exists.
- **Memory prices.** In November 2026 DDR5 costs about 1.7 times as much as DDR4 at Shop.kz (16 GB: 122,990 vs 72,990 KZT). The request assumes "a computer" has one price; in practice the memory type decides the budget.

**What I would ask Daniyar:**

1. Does the budget include the operating systems, keyboards/mice and UPS, or only computers and monitors?
2. What exactly does the designer do — print and web graphics, or also video? Video changes the GPU and storage a lot.
3. Does the developer have to use Windows (for example for .NET or a client's Windows-only tools), or is Linux fine?
4. How many years is "a few", and will the machines be upgraded or replaced at the end?
5. Is there a file server or cloud storage for backups and old projects?

**What I assumed instead:** everything (computers, monitors, OS, keyboard and mouse, webcam, UPS) must fit in 3,000,000 KZT; "a few years" = 4–5 years; the designer does print/web graphics plus light video; the developer works on Linux; the company has or will set up shared storage for backups; prices are taken from one vendor that delivers across Kazakhstan, so the order is one delivery and one warranty contact.

## 3. What I did

1. Wrote down the load of each role, then the bottleneck that load creates, before choosing any part (the reasoning per machine is in [builds.md](builds.md)).
2. Checked current prices at Shop.kz for every candidate part on 16.11.2026. The DDR4/DDR5 price gap changed the plan: the two office machines moved to AM4 + DDR4, and the saved money went to their real bottlenecks (32 GB for sales, a better monitor and a UPS for the accountant).
3. Picked parts so the money goes to each bottleneck, and checked compatibility (socket, memory type, M.2, power) on PCPartPicker; cooler height against the case I checked in the makers' specifications (AK400 155–156 mm, case limit 165 mm), because PCPartPicker does not check all physical sizes.
4. Listed every part with price, link and date in [budget.csv](budget.csv), saved as UTF-8.

| Role | Platform | Memory | Where the money went | Total, KZT |
| --- | --- | --- | --- | --- |
| Accountant | Ryzen 5 PRO 5650G, AM4 | 16 GB DDR4 | adjustable monitor, UPS | 578,400 |
| Sales | Ryzen 5 PRO 5650G, AM4 | 32 GB DDR4 | memory, webcam | 584,590 |
| Web developer | Ryzen 7 7700, AM5 | 32 GB DDR5 | memory, 8 cores; free Ubuntu | 637,100 |
| Designer | Ryzen 7 7700, AM5 + RTX 5060 | 32 GB DDR5 | calibrated 4K monitor, GPU | 1,143,680 |
| **All four** | | | | **2,943,770** |

Every machine meets the hard requirements: at least 16 GB memory, a 1 TB SSD, a licensed OS (Windows 11 Pro ×3, Ubuntu 26.04 LTS ×1), its own monitor. Reserve: 56,230 KZT.

### The director's three questions

**1. Which machine will you upgrade first, eighteen months from now, and why?**
The **web developer's memory: 32 GB → 64 GB**. Containers, databases and test VMs grow every year, and memory is already the first limit in that role. The MSI PRO B650M-P has two free slots, so it is two more 16 GB DDR5 sticks, no other change. Waiting 18 months is also deliberate: DDR5 is unusually expensive now (245,980 KZT for 32 GB), and buying the second half later is likely to be cheaper — though that is a forecast, not a certainty.

**2. Price the same four as pre-built machines from a vendor. What does the company gain and lose?**

Shop.kz sells ready-made machines under its own brand WW-KZ. The closest ones (screenshots `prebuilt-office.png`, `prebuilt-designer.png`, 16.11.2026):

| Role | Pre-built at Shop.kz | Price on 16.11.2026, KZT | What it misses | Price after fixing that, KZT | Our system unit, KZT |
| --- | --- | --- | --- | --- | --- |
| Accountant | [WW-KZ office: Core i5-14400, 16 GB DDR5, 512 GB SSD](https://shop.kz/offer/kompyuter-ofisnyy-ww-kz-intel-core-i5-14400-512-gb-ssd-16-gb-ddr-5/) | 374,490 | 512 GB SSD (requirement is 1 TB): + 1 TB SSD 74,990 | 449,480 | 356,730 |
| Sales | same office machine | 374,490 | + 1 TB SSD, + 16 GB DDR5 122,990 | 572,470 | 401,730 |
| Web developer | same office machine | 374,490 | + 1 TB SSD, + 16 GB DDR5 | 572,470 | 553,120 |
| Designer | [WW-KZ gaming: Ryzen 5 7500F, RTX 5060 8 GB, 16 GB DDR5 (1x16), 1 TB SSD](https://shop.kz/offer/kompyuter-igrovoy-ww-kz-amd-ryzen-5-7500f-rtx-5060-8-gb-1-tb-ssd-16-gb-ddr-5/) | 707,790 | + 16 GB DDR5 | 830,780 | 886,710 |
| **Total** | | **1,831,260** | | **2,425,200** | **2,198,290** |

"System unit" = everything except monitor, OS, keyboard/mouse, webcam and UPS, which are the same in both cases. The upgrade prices are the same Shop.kz parts as in budget.csv. I assumed the pre-builts have a free M.2 slot and a free memory slot; the pages do not say, so I am not sure the upgrades fit without replacing parts.

**What the company gains with pre-built machines:** they arrive assembled and tested, with one warranty per machine from the shop instead of a separate warranty for every part; nobody in the company spends a day building four PCs; if one breaks, the whole unit goes back to one place.
**What it loses:** as sold, the pre-builts fail the hard requirements (512 GB SSD on the office model, 16 GB everywhere, so no 32 GB for sales, the developer or the designer) and Windows is not included (the office page offers only "installation" for +5,000 KZT; the licence is extra). Fixed to meet the requirements they cost **226,910 KZT more** than our parts, and with the same monitors, OS and peripherals the total would be about **3,170,680 KZT — over the 3,000,000 budget**. The company also loses the choice: the accountant would pay for a Core i5-14400 that is far more than spreadsheets need, the designer a 6-core CPU without built-in graphics, the power supply and motherboard brands are not named on the pages, and one 16 GB stick means single-channel memory until someone opens the case. Pre-built is only cheaper for the designer (by about 56,000 KZT), because a gaming PC already contains the GPU this job needs.

**3. Which of the four people will complain about performance within a month, and about what?**
The **designer, about disk space**. One terabyte holds the system, Adobe apps and caches, and then the projects; with layered PSD files and any video for social media it will be full within weeks. I chose 1 TB (the requirement) instead of 2 TB to keep the calibrated monitor and the RTX 5060 in budget. The fix is cheap and is the first thing the 56,230 KZT reserve or the next budget should go to: an extra NVMe drive, or moving finished projects to shared storage. The 8 GB of video memory on the RTX 5060 is the second weak spot if video work grows.

## 4. Evidence

- [builds.md](builds.md) — four builds, each with load, bottleneck, trade-off and the alternative not taken
- [budget.csv](budget.csv) — every part: role, component, model, price in KZT, link to the vendor page, date; totals per role and grand total
- [evidence/pcpartpicker-links.md](evidence/pcpartpicker-links.md) — one PCPartPicker list per build: compatibility and estimated power
- [evidence/vendor-quotes/](evidence/vendor-quotes/) — a screenshot of every price used, with the Shop.kz address and the date visible

## 5. What I would do differently

I would ask for a **written quote from the vendor for the whole order on one day** instead of 23 separate page screenshots. Shop.kz has a corporate-client service; one quote would lock the prices (the reserve is only about 2%, and DDR5 prices change week to week), show a delivery and assembly cost that the page prices do not include, and give one warranty document for all four machines.
