from blockWifiIp import stop
from blockWifiIp import getPID
import os, signal;
def killScript():
   pid =  getPID()
   print("Trying to kill process with PID: %s "% pid)
   #for UNIX systems
   os.kill(pid,signal.SIGKILL)
killScript()