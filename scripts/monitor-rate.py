#!/usr/bin/env python

import sys
import time
from sqlalchemy import *
from datetime import datetime, timedelta


def count(meta, tbl):
    return meta.bind.execute(select([func.count('*')], from_obj=tbl)).scalar()

def monitor(url, tablename, total):
    meta = MetaData()
    engine = create_engine(url)
    meta.bind = engine
    tbl = Table(tablename, meta, autoload=True)

    last_num = last_time = rate = None
    while True:
        current_num = count(meta, tbl)
        current_time = time.time()
        if last_time and last_num:
            rate = (current_num - last_num) / (current_time - last_time)
            out_str = "%d rows: %0.2f per second" % (current_num, rate)
        else:
            out_str = "%d rows: initializing" % current_num
        last_num = current_num
        last_time = current_time

        if total and rate:
            to_go = total - current_num
            remaining = (to_go / rate)
            est_finish = datetime.now() + timedelta(seconds=remaining)
            out_str += (" - est completion: %s" %
                        est_finish.strftime('%a %d - %H:%M:%S %p'))

        print out_str

        time.sleep(5)


if __name__ == '__main__':
    if len(sys.argv) < 3:
        print "usage: %s <url> <table name>"
    else:
        url = sys.argv[1]
        table_name = sys.argv[2]
        if len(sys.argv) > 3:
            total = int(sys.argv[3])
        else:
            total = None
        print "Checking rate for %s on %s" % (table_name, url)
        monitor(url, table_name, total)
