#!/usr/bin/env python3.7
import requests
import json
import os
import re
import sys
api_key = "W7meYzZdEndQGBycVONls8cYU8FBGsnMNoirAwAplMtVz8c1g7M7eR89HJcZaGXfT0i+KwcPpfAwBdy2"
api_secret = "t7BuWrgGciJeMp3hatlofJ4JufoWtDDwHc3XuZGxC28ratSvZzqLmH+yslZB1YbLk0KXJVXdYJGunS0W"
firewall_ip = "10.0.0.5"
url = "http://"+firewall_ip+"/"
ip = sys.argv[1]

monitored_intf = "lan"
network = "10.0.0.0/24"
aliasName = "LAN"


def isConnected():
    connected = False
    r = requests.get(url+"api/diagnostics/interface/getArp",
                     auth=(api_key, api_secret), verify=False)
    if r.status_code == 200:
        response = json.loads(r.text)
        # check if there is a client with that ip on the monitored interface
        for host in response:
            if host["ip"] == ip:
                interface = host["intf_description"]
                print("Host is connected on %s" % interface)
                if interface == monitored_intf:
                    print("Correct interface")
                    connected = True
    else:
        print("Request failed with error code %s" % r.status_code)
    return connected


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


if not isConnected():
    blockTraffic(True)
else:
    blockTraffic(False)
    print("Unlocking traffic...")
