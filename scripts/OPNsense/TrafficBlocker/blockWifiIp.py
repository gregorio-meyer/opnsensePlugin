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
from parse import parse
api_key = "W7meYzZdEndQGBycVONls8cYU8FBGsnMNoirAwAplMtVz8c1g7M7eR89HJcZaGXfT0i+KwcPpfAwBdy2"
api_secret = "t7BuWrgGciJeMp3hatlofJ4JufoWtDDwHc3XuZGxC28ratSvZzqLmH+yslZB1YbLk0KXJVXdYJGunS0W"
firewall_ip = "10.0.0.5"
url = "http://"+firewall_ip+"/"
# prenderlo dalla config
monitored_intf = "lan"
network = "10.0.0.0/24"
aliasName = "LAN"
locked = False
traffic_blocker_config = '/usr/local/etc/trafficblocker/trafficblocker.conf'

# check connection with arp api


def isConnected(ip):
    connected = False
    r = requests.post(url+"api/diagnostics/interface/flushArp",
                      auth=(api_key, api_secret), verify=False)
    time.sleep(1)
    r = requests.get(url+"api/diagnostics/interface/getArp",
                     auth=(api_key, api_secret), verify=False)

    if r.status_code == 200:
        response = json.loads(r.text)
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


def ping(ip):
    # ping host
    result = os.system('ping -t2 -c 4 ' + ip)
    return True if result == 0 else False


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
    # This will add alias since it's not present
    if len(resp) == 0:
        return None
    else:
        return resp["uuid"]

# locks / unlocks traffic toward network using an alias


def blockTraffic(lock):
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


def checkIftop(ip):
    print("Trying to make iftop call")
    result  = ping(ip)
    print("Ping result ",result)
    #result = os.system("iftop -i em1 -t -s 1")
 #   result = subprocess.check_output("'iftop -i em1 -t -s 1'", shell=False)
    print("result ", result)
    #print("out ", sys.stdout)
    exit(0)
    # connected = False
    # #parse result and returns a report
    # if isinstance(result,int):
    #     print(result)
    # else:
    #     print("Parsing")
    #     r = parse(result)
    #     print("Report: ", r)
    #     connected = r.isConnected(ip)
    # print("Connected: ", connected)
    # exit(0)
    # #print(result)
    # threading.Timer(1, checkIftop, [ip]).start()


def checkPing(ip):
    if not ping(ip):
        global locked
        # if not locked lock
        if not locked:
            print("Not locked, lock")
            blockTraffic(True)
            locked = True
            # if the connection is already locked continue
        print("Already locked")
    else:
        # if locked unlock
        if locked:
            print("Locked, unlock")
            blockTraffic(False)
            locked = False
        print("Already unlocked")
    threading.Timer(1, checkPing, [ip]).start()


attempts = 0


def check(ip):
    # check for
    if not isConnected(ip):
        global attempts
        global locked
        attempts += 1
        print("Attempts %s" % attempts)
        # number of connection checks before disabling connection
        if attempts > 10:
            attempts = 0
            # if not locked lock
            if not locked:
                print("Not locked, lock")
                blockTraffic(True)
                locked = True
            # if the connection is already locked continue
            print("Already locked")
    else:
        attempts = 0
        # if locked unlock
        if locked:
            print("Locked, unlock")
            blockTraffic(False)
            locked = False
        print("Already unlocked")
    threading.Timer(1, check, [ip]).start()


if __name__ == '__main__':
    print("Program starts...")
    try:
        if len(sys.argv) > 1 and sys.argv[1] != "&":
            print("Taking ip from command line")
            ip = sys.argv[1]
        else:
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
            checkIftop(ip)
            # check(ip)
            # checkPing(ip)
        except Exception as e:
            print("Check failed %s" % e)
    except Exception as e:
        print("Get ip failed %s" % e)
