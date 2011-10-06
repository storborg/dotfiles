import random
import sys
import string

if len(sys.argv) > 1:
    length = int(sys.argv[1])
else:
    length = 16

choose_from = string.letters + string.digits + '__' + '-|@.,?/!~#$%^&*(){}[]\+=.'

print ''.join([random.choice(choose_from) for xx in range(length)])
