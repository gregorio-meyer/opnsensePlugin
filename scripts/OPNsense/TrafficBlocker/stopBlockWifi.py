#!/usr/bin/env python3.7
print("Stopping traffic blocker..")
import sys
from subprocess import check_call
script = "blockWifiIp.py"
result = check_call(["pkill", "-9", "-f", script])
print("Result %s "% result)