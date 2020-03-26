#!/usr/bin/env python3.7
from subprocess import check_call
import sys
print("Stopping traffic blocker..")
script = "blockWifiIp.py"
try:
    check_call(["pkill", "-9", "-f", script])
except Exception as e:
    print("Failed:%s" % e)
#print("Result %s " % result)
