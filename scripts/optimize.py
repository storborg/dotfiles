"""
Run various system optimizations.
"""

import os

tasks = {
    # Clean the Mail.app index
    'vacuum mail index': 'sqlite3 ~/Library/Mail/Envelope\ Index vacuum;'
}

if __name__ == '__main__':
    for k, v in tasks.items():
        conf = raw_input(k + "? ")
        if conf.lower().startswith('y'):
            print "running '%s'..." % k
            if type(v) is str:
                os.system(v)
            print "done"
        else:
            print "skipped '%s'" % k

