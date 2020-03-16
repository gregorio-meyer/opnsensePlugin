#!/usr/bin/env python3.7
import requests
import json

print("Program starts...")
# key + secret from downloaded apikey.txt
api_key = 'W7meYzZdEndQGBycVONls8cYU8FBGsnMNoirAwAplMtVz8c1g7M7eR89HJcZaGXfT0i+KwcPpfAwBdy2'
api_secret = 't7BuWrgGciJeMp3hatlofJ4JufoWtDDwHc3XuZGxC28ratSvZzqLmH+yslZB1YbLk0KXJVXdYJGunS0W'
# request settings
interface = "lan"
mac_address = "08:00:27:c1:69:45"
descr = "Test"


# define the basics, hostname to use and description used to identify our test rule
url = "http://10.0.0.5/api/wol/wol/addHost"
# add wake on lan
# create a new rule, identified by rule_description allowing traffic from
# 192.168.0.0/24 to 10.0.0.0/24 using TCP protocol
data = {"host": {"interface": interface,
                 "mac": mac_address, "descr": descr}}
r = requests.post(url, auth=(api_key, api_secret),
                  verify=False, json=data)
if r.status_code == 200:
    print("Request succesful")
else:
    print("Request failed with status code %s" % r.status_code)
print("Response: %s" % r.text)
    