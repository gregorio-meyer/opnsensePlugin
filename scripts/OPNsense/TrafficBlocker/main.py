import blockWifiIp
import stopBlockWifi
import multiprocessing
import time
import threading
from blockWifiIp import start

def run():
    #run it for 10 seconds
    #start blockWifi.start() as a process 
    print("Checking host connections") 
    p = multiprocessing.Process(target=start,name="Start", args=(10,))
    p.start()
    time.sleep(10)
#stop and update the view
    p.terminate()
    p.join()
    print("Check ended")
    #run it every 10 seconds
    threading.Timer(10, run).start()

#nuova funzione che stoppa main -> trafficblocker stop

if __name__ == "__main__":
    print("Running...")
    run()
else:
    print("Not running")

