"""
Set up aliases for dotfiles and folders.
"""

import os
import sys


def safe_symlink(dest, src):
    print("linking %s -> %s" % (src, dest))
    try:
        os.symlink(dest, src)
    except OSError:
        print("  skipping! file already exists")


base = os.path.abspath(os.path.dirname(sys.argv[0]))
home = os.environ["HOME"]

for destfile in os.listdir(base):
    if destfile.startswith("dot.") and (destfile != "dot.config"):
        srcfile = ".%s" % destfile[4:]
        dest = os.path.join(base, destfile)
        src = os.path.join(home, srcfile)
        safe_symlink(dest, src)


dotconfig_path = os.path.join(home, ".config")
if not os.path.exists(dotconfig_path):
    os.makedirs(dotconfig_path)

base_config_path = os.path.join(base, "dot.config")
for destfile in os.listdir(base_config_path):
    dest = os.path.join(base_config_path, destfile)
    src = os.path.join(dotconfig_path, destfile)
    safe_symlink(dest, src)
