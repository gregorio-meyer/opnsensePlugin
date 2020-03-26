from subprocess import check_call
import sys

script = "blockWifiIp.py"


check_call(["pkill", "-9", "-f", script])
