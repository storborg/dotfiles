"""
Set up aliases for dotfiles and folders.
"""

import os
import sys

base = os.path.dirname(sys.argv[0])
home = os.environ["HOME"]

for destfile in os.listdir(base):
    if destfile.startswith("dot."):
        srcfile = ".%s" % destfile[4:]
        dest = os.path.join(base, destfile)
        src = os.path.join(home, srcfile)
        print("linking %s -> %s" % (src, dest))
        try:
            os.symlink(dest, src)
        except OSError:
            print("  skipping! file already exists")
