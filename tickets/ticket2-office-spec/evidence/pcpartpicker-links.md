# PCPartPicker lists — compatibility and power

Checked on 16.11.2026. PCPartPicker does not price in tenge and does not list the Kazakhstan shop, so it was used **only for compatibility and estimated power**. Prices are in [../budget.csv](../budget.csv).

Some exact Shop.kz models are not in the PCPartPicker database. Where that happened, the closest part with the same socket / memory type / size was used, so the compatibility check is still valid:

| Shop.kz part | Used on PCPartPicker | Why it is equivalent for the check |
| --- | --- | --- |
| AMD Ryzen 5 PRO 5650G | AMD Ryzen 5 5600G | same AM4 socket, same 6 cores / 65 W, same built-in graphics; the PRO version is not listed |
| AMD Radeon R9 DDR4-3200 16 GB (1x16) | Kingston FURY Beast DDR4-3200 16 GB (1x16) | same type, speed and size |
| GeIL Pristine DDR4-3200 32 GB (2x16) | Kingston FURY Beast DDR4-3200 32 GB (2x16) | same type, speed and size |
| 2x AMD Radeon R5 DDR5-5200 16 GB | Kingston FURY Beast DDR5-5200 32 GB (2x16) kit | same type, speed and total size |

| Build | PCPartPicker list | Estimated wattage | PSU | Notes from PCPartPicker |
| --- | --- | --- | --- | --- |
| Accountant | https://pcpartpicker.com/list/VQpGdq | 159 W | 550 W | (1) A520M-A PRO needs BIOS 7C96v17 or newer for this CPU; (2) the case's front USB ports need header adapters on this board |
| Sales | https://pcpartpicker.com/list/BBMZqd | 174 W | 550 W | same two notes as the accountant (same board and CPU) |
| Web developer | https://pcpartpicker.com/list/c9V6K7 | 170 W | 550 W | the AK400 "may require a separately available mounting adapter" for AM5 |
| Designer | https://pcpartpicker.com/list/j8fHn2 | 315 W | 650 W | same AK400 / AM5 note |

**What I did about the notes:**

- **BIOS (accountant, sales).** If the boards arrive with an older BIOS, the BIOS must be updated before this CPU will start. I would ask Shop.kz to do it as part of assembly and testing. Risk: I do not know which BIOS version the boards in stock have.
- **Front USB (accountant, sales).** The A520M-A PRO has no USB 3.2 Gen 2 header, so the case's front USB-C port will not work without an adapter. Office users can use the rear USB ports; I accepted this instead of a more expensive board.
- **AK400 on AM5 (developer, designer).** AM5 uses the same mounting holes as AM4 ([DeepCool](https://uk.deepcool.com/company/pressroom/newsrelease/2022/16417.shtml)), and the AK400 is sold as AM4/AM5-compatible; the note is a general warning. Before assembly the box should be checked for the AM5 bracket.
- **Power.** The highest estimate is 315 W for the designer on a 650 W supply, about 50% load. The other three are under 175 W on 550 W. All four have enough headroom for a later upgrade (more memory, a second SSD).
