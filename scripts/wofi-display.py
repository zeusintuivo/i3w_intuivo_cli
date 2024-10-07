#!/usr/bin/env python2

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
     "wofi",
     "-i", "--dmenu",
     "--lines", str(lines),
     "--height", str(lines*8),
     "--width", str(width*7),
     "-p", "display configuration"
     ]
wofi = Popen(array_list, stdout=PIPE, stdin=PIPE)
# flat_string = ' '.join(array_list)
# print(flat_string)

selected = wofi.communicate(
        "\n" \
        .join(sorted(fdict.keys())) \
        .encode("utf-8"))[0] \
        .decode("utf-8") \
        .strip()

wofi.wait()

r = subprocess.Popen([fdict[selected]])
r.wait()
