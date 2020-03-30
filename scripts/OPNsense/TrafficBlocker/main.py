import blockWifiIp
import stopBlockWifi
import multiprocessing
import time
import threading
from blockWifiIp import start
from stopBlockWifi import stop

def run():
    #run it for 10 seconds
    #start blockWifi.start() as a process   
    p = multiprocessing.Process(target=start,name="Start", args=(10,))
    p.start()
    time.sleep(10)
#stop and update the view
    p.terminate()
    p.join()
    #run it every 10 seconds
    threading.Timer(10, run).start()

#nuova funzione che stoppa main -> trafficblocker stop

if __name__ == "__main__":
    run()

