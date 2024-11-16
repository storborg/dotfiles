#!/usr/bin/env python

"""
Functions for doing aggregate stuff with nginx log files.

Call me with ./nginx-logs.py <mode> [file1] [file2] ...

Or no files to use stdin.

This is the format we usually use:
log_format  main '$remote_addr - $remote_user [$time_local] $status "$request" $body_bytes_sent "$http_referer" "$http_user_agent" "$http_x_forwarded_for"';
"""

import sys
import re
import fileinput
from datetime import datetime, timedelta
from collections import defaultdict, namedtuple
from operator import itemgetter


nginx_main_log_re = re.compile(
    r'(?P<remote_addr>\d+\.\d+\.\d+\.\d+)'
    r'\ -\ '
    r'(?P<remote_user>\S+)'
    r'\ '
    r'\[(?P<time_local>[^\]]+)\]'
    r'\ '
    r'(?P<status>\d{3})'
    r'\ '
    '\"'
        '(?P<method>[A-Z]+)'
        r'\ '
        r'(?P<url>\S+)'
        r'\ '
        r'(?P<http_version>HTTP\/1\.(0|1))'
    '\"'
    r'\ '
    r'(?P<body_bytes_sent>\d+)'
    r'\ '
    '\"(?P<referer>\\S+)\"'
    r'\ '
    '\"(?P<user_agent>[^"]+)\"'
    r'\ '
    '\"(?P<http_x_forwarded_for>[^"]+)\"$')


time_re = re.compile(r'(?P<main>.+)\ (?P<sign>[+-])(?P<offset_hours>\d{2})\d{2}$')


Request = namedtuple('Request',
                     ['remote_addr', 'remote_user', 'time_local', 'status',
                      'method', 'url', 'http_version', 'body_bytes_sent',
                      'referer', 'user_agent', 'http_x_forwarded_for'])


def parse_line(s):
    m = nginx_main_log_re.match(s)
    if not m:
        print "Failed to parse line! Was %r" % s
        return

    time_m = time_re.match(m.group('time_local'))
    if not time_m:
        print "Failed to parse time! Was %r" % s
        time_local = None
    else:
        time_local = datetime.strptime(time_m.group('main'), '%d/%b/%Y:%H:%M:%S')
        sign = time_m.group('sign')
        offset = int(time_m.group('offset_hours'))
        if sign == '+':
            time_local -= timedelta(hours=offset)
        else:
            time_local += timedelta(hours=offset)

    return Request(remote_addr=m.group('remote_addr'),
                   remote_user=m.group('remote_user'),
                   time_local=time_local,
                   status=int(m.group('status')),
                   method=m.group('method'),
                   url=m.group('url'),
                   http_version=m.group('http_version'),
                   body_bytes_sent=int(m.group('body_bytes_sent')),
                   referer=m.group('referer'),
                   user_agent=m.group('user_agent'),
                   http_x_forwarded_for=m.group('http_x_forwarded_for'))


def readable_bytes(n):
    n = float(n)
    for exponent, prefix in ((5, 'P'),
                             (4, 'T'),
                             (3, 'G'),
                             (2, 'M'),
                             (1, 'K')):
        cutoff = (1024 ** exponent)
        if n >= cutoff:
            return "%0.2f %sB" % (n / cutoff, prefix)
    return "%d B" % n


def bandwidth_counter(lines):
    bandwidth_by_ip = defaultdict(int)
    for line in lines:
        req = parse_line(line)
        if not req:
            continue
        bandwidth_by_ip[req.remote_addr] += req.body_bytes_sent

    ips = bandwidth_by_ip.items()
    ips.sort(key=itemgetter(1), reverse=True)
    return ips


def bandwidth_hogs(lines):
    ips = bandwidth_counter(lines)
    for ip, bytes in ips[:50]:
        print "%s\t%s" % (ip, readable_bytes(bytes))


def top_with_status(lines, status):
    pages = defaultdict(int)
    for line in lines:
        req = parse_line(line)
        if req and req.status == status:
            pages[req.url] += 1

    pages = pages.items()
    pages.sort(key=itemgetter(1), reverse=True)
    return pages


def top_404s(lines):
    count_404s = top_with_status(lines, 404)
    for url, count in count_404s[:50]:
        print "%d\t%s" % (count, url)


if __name__ == '__main__':
    if len(sys.argv) > 1:
        funcname = sys.argv.pop(1)
    else:
        funcname = 'bandwidth_hogs'
    print "Using mode %s" % funcname
    func = globals()[funcname]
    import fileinput
    ret = func(fileinput.input())
    if ret:
        from pprint import pprint
        pprint(ret)
