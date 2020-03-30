#!/usr/bin/env python3.7
from subprocess import check_call
import sys
def stop():
    print("Stopping traffic blocker..")
    script = "main.py"
    try:
      check_call(["pkill", "-9", "-f", script])
    except Exception as e:
        print("Failed:%s" % e)


stop()
