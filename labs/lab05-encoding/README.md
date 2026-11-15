# Lab 5 — Encoding forensics

Name: Bostan Temirlan (no pair) · Date: 15.11.2026 · Tools: Git Bash (Git for Windows 2.56.0, UCRT64) on the Windows 11 host (Acer Nitro AN515-57), Excel, LibreOffice Calc

## What I received

`staff-broken.csv`, copied unchanged to `evidence/staff-broken.csv` (`cmp` with the downloaded file: identical).

- **Excel (double-click):** Russian names correct, Kazakh letters wrong (`Ә→Ј`, `Қ→Ќ`, `Ө→Ґ`, `Ұ→ў`, `Ү→Ї`, `ғ→є`: `Јбдірахманова`, `Ќасымов`, `Ґскемен`). Columns split correctly.
- **LibreOffice Calc:** import dialog default Character set "Automatic" → it guessed **Cyrillic (Windows-1251)**; separator detected as `;`. Same result as Excel: Russian correct, Kazakh wrong.
- **Terminal (`cat`):** Cyrillic letters shown as unreadable blocks — the terminal expects UTF-8, and single-byte codes are not valid UTF-8.

## Diagnosis (made before the fix)

Committed before the fix in `b5e0037` (`DIAGNOSIS.txt`).

- file said: `Non-ISO extended-ASCII text, with CRLF line terminators` (evidence/file-before.txt)
- First 16 bytes: `49 44 3b d4 e0 ec e8 eb e8 ff 3b c8 ec ff 3b ce` = `ID;Фамилия;Имя;О` (evidence/hexdump-before.txt)
- **Encoding: KZ-1048** (`RK1048` in iconv) — because one byte per letter (`Ф = D4`, `а = E0`), and the Kazakh letter `Ә` in `Әбдірахманова` (offset `0x2a`) is the single byte `A3`. In KZ-1048 `A3 = Ә`; in Windows-1251 `A3 = Ј` — exactly what Excel and LibreOffice showed. `iconv -f WINDOWS-1251` breaks the Kazakh letters, `iconv -f RK1048` reads both Russian and Kazakh names correctly.
- **Line ending: CRLF** — because line 1 ends with `0D 0A` (offset `0x24–0x25`).
- **BOM: no** — because the file starts with `49 44` (`ID`). In the fixed file I **added** a UTF-8 BOM because the brief requires Excel to open the file correctly by double-click; without a BOM Excel reads UTF-8 as Windows-1251. Cost: Linux tools and scripts will see the BOM glued to the first column name (`ID`).
- **Separator:** `;` (byte `3B`). Kept — Excel in Russian/Kazakh locale expects `;`, so the columns split on double-click.
- **Line ending in the fixed file:** kept **CRLF** — this is a data file for Windows/Excel users, not a script, and the source was already CRLF, so no conversion was needed.

## Fix

`scripts/fix.sh`, run from `labs/lab05-encoding/` with `sh scripts/fix.sh`:

```sh
#!/bin/sh
# Lab 5: convert staff-broken.csv from KZ-1048 (RK1048) to UTF-8
in=evidence/staff-broken.csv
out=evidence/staff-fixed.csv
iconv -f RK1048 -t UTF-8 "$in" > "$out"            # 1. encoding
# 2. line endings: source is already CRLF - kept as is, no sed
# 3. BOM: added so Excel recognises UTF-8 on double-click
printf '\357\273\277' | cat - "$out" > tmp && mv tmp "$out"
```

## Verification

`evidence/file-after.txt`:
- file: `Unicode text, UTF-8 (with BOM) text, with CRLF line terminators`
- first bytes: `ef bb bf 49 44 3b d0 a4` = BOM + `ID;` + `Ф` as the two-byte UTF-8 pair `D0 A4`
- line 101: `31 30 31 3b d3 98 ...` = `101;Ә...` — `Ә` is now `D3 98` (was `A3`)

`evidence/opens-correctly.png`: Excel (double-click), LibreOffice Calc (Character set auto-detected as UTF-8, separator `;`) and `cat` in Git Bash side by side — all names correct, including Kazakh letters (Әбдірахманова, Қасымов, Нұрлан, Өмірзақова, Қарағанды, Өскемен).

## What did not work the first time

1. **Git silently changed the original's line endings.** After the first commit, `git ls-files --eol evidence/staff-broken.csv` showed `i/lf w/crlf`: with `core.autocrlf=true` Git stored the original with LF instead of CRLF — the evidence in the repo was no longer the file I received. Fix: `.gitattributes` with `*.csv -text` and `git add --renormalize .` → `i/crlf w/crlf attr/-text`, the bytes are stored as-is.
2. **The terminal font could not show some Kazakh letters.** With the default Git Bash font, `cat` of the correct UTF-8 file showed `Ә` like a small `ә` and gaps inside `Нұрлан`, `Жұмабаев`, although the bytes were right (`D3 98`). Fix: Git Bash Options → Text → Font → Cascadia Mono.
3. **Installing LibreOffice changed the default program for `.csv`**, so double-click opened LibreOffice instead of Excel. Fix: Open with → Excel → Always.

## Evidence

- [evidence/staff-broken.csv](evidence/staff-broken.csv) — the original, untouched (identical to the download)
- [evidence/staff-fixed.csv](evidence/staff-fixed.csv) — the result: UTF-8 with BOM, CRLF
- [evidence/file-before.txt](evidence/file-before.txt) — `file` before the fix
- [evidence/hexdump-before.txt](evidence/hexdump-before.txt) — first 8 lines of `xxd` before the fix
- [evidence/file-after.txt](evidence/file-after.txt) — `file` and `xxd` after the fix, plus the bytes of line 101
- [evidence/opens-correctly.png](evidence/opens-correctly.png) — Excel, LibreOffice and terminal showing the fixed file
- [DIAGNOSIS.txt](DIAGNOSIS.txt) — the diagnosis, committed before the fix
- [scripts/fix.sh](scripts/fix.sh) — the conversion
- [.gitattributes](.gitattributes) — keeps the CSV bytes unchanged in Git
