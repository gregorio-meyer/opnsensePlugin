#!/usr/bin/env python3.7
import requests
import json
import os
import re
import sys
import time
import subprocess
import threading
from configparser import ConfigParser
api_key = "wPzuUuXBKg3k4cWwkJHFYbiekVZ8qhbcvXKJwSBUhLjc/UoHyXfWlXprYL3eW8GnqZatQoBcDLhFIACM"
api_secret = "yfJOr5FPs1oGvUI75NMo3EiKZm6Tfgzzm7HBX6SAEnUAR3FQvBbK48fIsAMmGlf02YebETLj0W0AlCuC"
firewall_ip = "10.0.0.5"
url = "http://"+firewall_ip+"/"
# prenderlo dalla config
monitored_intf = "lan"
network = "10.0.0.0/24"
aliasName = "LAN"
locked = None
traffic_blocker_config = '/usr/local/etc/trafficblocker/trafficblocker.conf'


def addAlias():
    data = {"alias": {"enabled": "1", "name": aliasName, "type": "network", "proto": "",
                      "updatefreq": "", "content": network, "counters": "0", "description": "Alias for "+aliasName}}
    r = requests.post(url+"api/firewall/alias/addItem",
                          auth=(api_key, api_secret), verify=False, json=data)
    if r.status_code == 200:
        print("Added alias %s" % aliasName)
    else:
        print("Adding alias failed with status code %s" % r.status_code)


def reconfigureAlias():
   # print("Reconfiguring aliases...")
    r = requests.post(url+"api/firewall/alias/reconfigure",
                          auth=(api_key, api_secret), verify=False, json={})
    if not r.status_code == 200:
        print("Reconfigure failed, status code: %s" % r.status_code)


def setAlias(uuid, data):
    #print("Setting alias...")
    r = requests.post(url+"api/firewall/alias/setItem/"+uuid,
                      auth=(api_key, api_secret), verify=False, json=data)
    # reconfigure alias to use it in firewall rules
    if r.status_code == 200:
        reconfigureAlias()
    else:
        print("Set alias failed with status code %s" % r.status_code)


def getUUID():
    r = requests.get(url+"api/firewall/alias/getAliasUUID/" +
                     aliasName, auth=(api_key, api_secret), verify=False)
    resp = json.loads(r.text)
    # This will add alias since it's not present
    if len(resp) == 0:
        return None
    elif 'message' in resp:
        if resp['message'] == "Authentication Failed":
            raise Exception("API authentication failed")
    elif 'uuid' in resp:
        return resp["uuid"]
    else:
        raise Exception("Get Alias returned wrong response ", resp)

# locks / unlocks traffic toward network using an alias


def blockTraffic(lock, ip):
    if lock:
        print(ip + " is not connected, blocking traffic towards the network")
        data = {"alias": {"enabled": "1", "name": aliasName, "type": "network", "proto": "",
                          "updatefreq": "", "content": network, "counters": "0", "description": "Alias for "+aliasName}}
    else:
        print(ip + " is connected, unlocking traffic towards the network")
        data = {"alias": {"enabled": "1", "name": aliasName, "type": "network", "proto": "", "updatefreq": "",
                          "content": "", "counters": "0", "description": "Alias for "+aliasName+"(Disabled)"}}
    uuid = getUUID()
    # Add alias since it's not present
    if uuid is None:
        addAlias()
    # modify existing alias
    else:
        setAlias(uuid, data)


def unlockTraffic():
    print("Unlocking traffic....")
    data = {"alias": {"enabled": "1", "name": aliasName, "type": "network", "proto": "", "updatefreq": "",
                      "content": "", "counters": "0", "description": "Alias for "+aliasName+"(Disabled)"}}
    uuid = getUUID()
    print("UUID is ", uuid)
    # Add alias since it's not present
    if uuid is None:
        addAlias()
    # modify existing alias
    else:
        setAlias(uuid, data)
    print("Traffic unlocked")


def checkNmap(ip):
    interface = "em1"
    try:
        p = subprocess.check_output("nmap -sP -e "+interface+" "+ip, stderr=subprocess.STDOUT,
                                    shell=True)
    except subprocess.CalledProcessError as e:
        print(e.output)
        print('Error running command: ' + '"' +
              e.cmd + '"' + ' see above shell error')
        print('Return code: ' + str(e.returncode))
    return isConnected(p.decode("ascii"))


def blockNmap(ip):
    print("Checking ip: ", ip)
    #global locked
    connected = checkNmap(ip)
    # it needs to be unlocked
    if connected and locked == True:
        # if locked unlock
       # if locked:
        print("Locked, unlock")
        blockTraffic(False, ip)
        locked = False
     #   else:
       #     print("Already unlocked")
    # it needs to be locked
    elif not connected and locked = False
        print("Not locked, lock")
        blockTraffic(True, ip)
        locked = True
    else:
        if locked == None:
           print("Locked not set")
        elif locked = True:
           print("Already locked")
        elif locked = False:
           print("Already unlocked")
        else:
            print("Error locked is ", locked)
       # if not locked lock
       # da sostituire con status
      #  if not locked:
        
        #    locked = True
        # else:
        #   print("Already locked")

    threading.Timer(1, blockNmap, [ip]).start()


def isConnected(string):
    if "Host seems down" in string:
        return False
    else:
        return True


def start():
   # print("Program starts...")
    try:
        if len(sys.argv) > 1 and sys.argv[1] != "&":
          #  print("Taking ip from command line")
            ip = sys.argv[1]
            print("Ip ", ip)
        else:
            # it takes the old one
            print("Looking for config...")
            # take ip from conf
            if os.path.exists(traffic_blocker_config):
                cnf = ConfigParser()
                cnf.read(traffic_blocker_config)
                if cnf.has_section('general'):
                    ip = cnf.get('general', 'Ip')
                    print("Found ip in config: %s" % ip)
                else:
                    # empty config
                    print("empty configuration")
            else:
                # no config
                print("no configuration file found")
        try:
            blockNmap(ip)
        except Exception as e:
            print("Check failed %s" % e)
    except Exception as e:
        print("Get ip failed %s" % e)
