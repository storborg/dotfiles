#!/usr/bin/python

import atexit
import os

# Try to import readline, and if it's available, do some useful completion
# and history tracking.
try:
    import readline
except ImportError:
    pass
else:

    readline.parse_and_bind("tab: complete")

    histfile = os.path.join(os.environ["HOME"], ".python_history")
    try:
        readline.read_history_file(histfile)
    except IOError:
        pass

    atexit.register(readline.write_history_file, histfile)
    del os, histfile
