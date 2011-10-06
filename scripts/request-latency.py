import sys
import re
from time import strptime
from pprint import pprint


def parse_line(s):
    fields = s.split()
    d = {}
    d['timestamp'] = strptime("%s %s" % (fields[0], fields[1]),
                              "%Y-%m-%d %H:%M:%S,%f")
    d['request_time'] = float(fields[4])
    d['db_time'] = float(fields[5])
    d['db_queries'] = float(fields[6])
    d['ip'] = fields[7]
    d['method'] = fields[8]
    d['url'] = fields[9]
    return d


arr = []
for line in sys.stdin.readlines():
    try:
        t = parse_line(line)['request_time']
    except IndexError:
        print "Failed on %r" % line
    else:
        arr.append(t)


arr.sort()
l = len(arr)

buckets = 100
inc = l / buckets

results = []

for ii in range(1, buckets + 1):
    index = ii * inc
    results.append((ii, arr[index]))


pprint(results)
