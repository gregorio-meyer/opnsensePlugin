<<<<<<< HEAD
from subprocess import check_call
import sys

script = "blockWifiIp.py"


check_call(["pkill", "-9", "-f", script])
=======
from blockWifiIp import stop
from blockWifiIp import getPID
import os, signal;
def killScript():
   pid =  getPID()
   print("Trying to kill process with PID: "+pid)
   #for UNIX systems
   os.kill(pid,signal.SIGKILL)
stop()
>>>>>>> 8e85a0ae9a5caa5f82a6b104c2e92dbbd4e45dbe
