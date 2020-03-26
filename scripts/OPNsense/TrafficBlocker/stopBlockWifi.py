#!/usr/bin/env python3.7
import sys
from subprocess import check_call
print("Start..")
script = "blockWifiIp.py"


check_call(["pkill", "-9", "-f", script])
