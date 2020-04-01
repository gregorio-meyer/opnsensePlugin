import blockWifiIp
import multiprocessing
import time
import threading
from blockWifiIp import start

#TODO aggiungere costanti per quanto deve girare e ogni quanto deve girare
def run():
    # start blockWifi.start() as a process
    print("Checking host connections")
    p = multiprocessing.Process(target=start, name="Start")
    p.start()
    # run it for 10 seconds
    time.sleep(10)
    # stop and update the view
    p.terminate()
    p.join()
    print("Check ended")
    # run it every 10 seconds
    threading.Timer(10, run).start()


try:
    run()
except Exception as e:
    print(e)