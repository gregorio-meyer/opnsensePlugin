#!/usr/bin/env python3.7
import requests
import json
import os
import re
import sys
import time
import subprocess
import threading
api_key = "W7meYzZdEndQGBycVONls8cYU8FBGsnMNoirAwAplMtVz8c1g7M7eR89HJcZaGXfT0i+KwcPpfAwBdy2"
api_secret = "t7BuWrgGciJeMp3hatlofJ4JufoWtDDwHc3XuZGxC28ratSvZzqLmH+yslZB1YbLk0KXJVXdYJGunS0W"
firewall_ip = "10.0.0.5"
url = "http://"+firewall_ip+"/"
# prenderlo dalla config
ip = 0

monitored_intf = "lan"
network = "10.0.0.0/24"
aliasName = "LAN"
locked = False

# check connection with arp api


def isConnected(ip):
    connected = False
    r = requests.post(url+"api/diagnostics/interface/flushArp",
                      auth=(api_key, api_secret), verify=False)
    time.sleep(1)
    # os.system('ping -t2 -c 4 '+ip)
    r = requests.get(url+"api/diagnostics/interface/getArp",
                     auth=(api_key, api_secret), verify=False)

    if r.status_code == 200:
        response = json.loads(r.text)
       # print(response)
        # check if there is a client with that ip on the monitored interface
        for host in response:
            if host["ip"] == ip:
                interface = host["intf_description"]
                # print(host)
                if interface == monitored_intf:
                   # print("Host is connected on %s" % interface)
                    connected = True
    else:
        print("Request failed with error code %s" % r.status_code)
    return connected


def isConnected2():
    # ping host
    print("Start...")
    os.system("ping -c 10.0.0.100")


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
    print("Reconfiguring aliases...")
    r = requests.post(url+"api/firewall/alias/reconfigure",
                          auth=(api_key, api_secret), verify=False, json={})
    if not r.status_code == 200:
        print("Reconfigure failed, status code: %s" % r.status_code)


def setAlias(uuid, data):
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
    # Add alias since it's not present
    if len(resp) == 0:
        return None
    else:
        return resp["uuid"]


def blockTraffic(lock):
    if lock:
        print(ip+" is not connected, blocking traffic towards the network")
        data = {"alias": {"enabled": "1", "name": aliasName, "type": "network", "proto": "",
                          "updatefreq": "", "content": network, "counters": "0", "description": "Alias for "+aliasName}}
    else:
        print(ip+" is connected, unlocking traffic towards the network")
        data = {"alias": {"enabled": "1", "name": aliasName, "type": "network", "proto": "", "updatefreq": "",
                          "content": "", "counters": "0", "description": "Alias for "+aliasName+"(Disabled)"}}
    uuid = getUUID()
    # Add alias since it's not present
    if uuid is None:
        addAlias()
    # modify existing alias
    else:
        setAlias(uuid, data)


i = 0
notConnected = 0
running = True
pid = 0

def stop():
    global running
    running = False
    print("Stopped")

def getPID():
    return pid

def check(ip):
    if(not running):
        print("Stopping...")
        exit(0)
    if not isConnected(ip):
        global notConnected
        global i
        global locked
        print(i)
        notConnected += 1
        print(notConnected)
        if notConnected >= 20:
            if not locked:
                print("Not locked, lock")
                blockTraffic(True)
                locked = True
            print("Already locked")
            notConnected = 0
    else:
        
        # if the connection is already unlocked continue
        if locked:
            print("Locked, unlock")
            blockTraffic(False)
            locked = False
        print("Already unlocked")
        notConnected = 0
        i += 1
    threading.Timer(1, check,[ip,pid]).start()

if __name__ == '__main__':
    ip = sys.argv[1]
    pid = os.getpid()
    check(ip,pid)
