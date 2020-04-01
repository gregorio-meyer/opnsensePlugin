#!/usr/bin/env python3.7
from subprocess import check_call
from blockWifiIp import unlockTraffic

import sys
def stop():
    print("Stopping traffic blocker..")
    #TODO this is dangerous give it a weirder name
    script = "main.py"
    try:
      check_call(["pkill", "-9", "-f", script])
    except Exception as e:
        print("Failed:%s" % e)

try:
    #TODO check if it should also enable connection
    #unlockTraffic()
    stop()
except Exception as e:
    print(e)