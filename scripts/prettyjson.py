import pprint
import sys

try:
    import simplejson as json
except ImportError:
    import json


obj = json.load(sys.stdin)
pprint.pprint(obj)
