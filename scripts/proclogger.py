import json
import time
import os.path
import sys


class JSONWriter(object):
    """
    Writes a json array to a file, incrementally. Intended for logging giant
    arrays of JSON without keeping the whole contents of the array in memory.
    When closed, the array will be terminated.
    """
    def __init__(self, f):
        self.f = f
        self.f.write('[\n')

    @classmethod
    def open(cls, fname):
        return cls(open(fname, 'w'))

    def close(self):
        self.f.write(']\n')

    def write(self, obj):
        json.dump(obj, self.f)
        self.f.write(',\n')
        self.f.flush()



class ProcLogger(object):
    """
    Periodically queries the contents of a /proc/* endpoint, and logs the result
    to a Writer class that implements the interface of JSONWriter. Don't
    instantiate this class directly, use a subclass which knows how to parse.
    """
    def __init__(self, writer_class=JSONWriter, interval=5):
        self.interval = interval
        self.writer = writer_class.open(self.make_filename())

    def make_filename(self):
        name = self.proc_path.lstrip('/').replace('/', '_')
        ii = 0
        while True:
            try_fname = "%s-%03d.json" % (name, ii)
            if not os.path.exists(try_fname):
                break
            ii += 1
        print "Writing to %s" % try_fname
        return try_fname

    def read(self):
        f = open(self.proc_path, 'r')
        s = f.read()
        f.close()
        return s

    def start(self):
        try:
            while True:
                self.writer.write(self.parse(self.read()))
                time.sleep(self.interval)
        finally:
            self.writer.close()


class MemInfoLogger(ProcLogger):
    """
    Logger to check /proc/meminfo and parse the result into a json dict.
    """

    proc_path = '/proc/meminfo'

    def parse(self, s):
        ret = {}
        for line in s.split('\n'):
            if line.strip() != '':
                key, val_s = line.split(':')
                val = val_s.split(' kB')[0].strip()
                if val.isdigit():
                    val = int(val)
                ret[key.strip()] = val
        return ret


if __name__ == '__main__':
    logger = MemInfoLogger()
    logger.start()
