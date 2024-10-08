#!/usr/bin/env python3

import os
import subprocess
from subprocess import Popen, PIPE

layout_dir = os.path.expanduser("~/.screenlayout")

fdict = dict()

for f in os.listdir(layout_dir):
    fp = os.path.join(layout_dir, f)
    n = os.path.splitext(f)[0]
    if n == '.dir_bash_history':
        continue
    fdict[n] = fp

lines = max(min(15, len(fdict)), 1);

if not fdict:
    width = len(max('1', key=len))
else:
    width = len(max(fdict.keys(), key=len))


# print(width)
# print("\n" \
# .join(sorted(fdict.keys())) \
# .encode("utf-8"))
array_list = [
     "rofi",
     "-i", "-dmenu",
     "-l", str(lines),
     "-height", str(lines*8),
     "-width", str(width*7),
     "-p", "display configuration"
     ]

rofi = Popen(array_list, stdout=PIPE, stdin=PIPE)
# flat_string = ' '.join(array_list)
# print(flat_string)

selected = rofi.communicate(
        "\n" \
        .join(sorted(fdict.keys())) \
        .encode("utf-8"))[0] \
        .decode("utf-8") \
        .strip()

rofi.wait()

r = subprocess.Popen([fdict[selected]])
r.wait()
