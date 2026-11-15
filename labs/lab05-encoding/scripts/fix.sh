#!/bin/sh
# Lab 5: convert staff-broken.csv from KZ-1048 (RK1048) to UTF-8
in=evidence/staff-broken.csv
out=evidence/staff-fixed.csv
iconv -f RK1048 -t UTF-8 "$in" > "$out"            # 1. encoding
# 2. line endings: source is already CRLF - kept as is, no sed
# 3. BOM: added so Excel recognises UTF-8 on double-click
printf '\357\273\277' | cat - "$out" > tmp && mv tmp "$out"
