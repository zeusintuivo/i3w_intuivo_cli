#!/usr/bin/env python2

import ConfigParser
import os
from subprocess import Popen, PIPE

remmina_dir = os.path.expanduser("~/.local/share/remmina")

fdict = dict()

for f in os.listdir(remmina_dir):
    fp = os.path.join(remmina_dir, f)
    c = ConfigParser.ConfigParser()
    c.read(fp)
    n = c.get('remmina', 'name')
    fdict[n] = fp

lines = max(min(15, len(fdict)), 1);

if not fdict:
    width = len(max('1', key=len))
else:
    width = len(max(fdict.keys(), key=len))


wofi = Popen(["wofi", "-i", "--dmenu", \
              "--lines", str(lines), "--width", str(width), \
              "-p", "connection"], stdout=PIPE, stdin=PIPE)
selected = wofi.communicate("\n" \
               .join(sorted(fdict.keys())) \
               .encode("utf-8"))[0] \
               .decode("utf-8") \
               .strip()
wofi.wait()

r = Popen(["remmina", "-c", fdict[selected]])
r.wait()
