import random
import string
import sys

if len(sys.argv) > 1:
    length = int(sys.argv[1])
else:
    length = 16

# choose_from = string.letters + string.digits + '__' + '-|@.,?/!~#$%^&*(){}[]\+=.'
choose_from = string.ascii_letters + string.digits

print("".join([random.choice(choose_from) for xx in range(length)]))
