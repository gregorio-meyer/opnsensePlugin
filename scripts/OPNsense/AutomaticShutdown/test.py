#!/usr/bin/env python3.7
import requests
import json

print("Program starts...")
# key + secret from downloaded apikey.txt
api_key = 'W7meYzZdEndQGBycVONls8cYU8FBGsnMNoirAwAplMtVz8c1g7M7eR89HJcZaGXfT0i+KwcPpfAwBdy2'
api_secret = 't7BuWrgGciJeMp3hatlofJ4JufoWtDDwHc3XuZGxC28ratSvZzqLmH+yslZB1YbLk0KXJVXdYJGunS0W'

# define the basics, hostname to use and description used to identify our test rule
url = "http://10.0.0.5/api/automaticshutdown/service/status"
# add wake on lan
# create a new rule, identified by rule_description allowing traffic from
# 192.168.0.0/24 to 10.0.0.0/24 using TCP protocol
r = requests.get(url, auth=(api_key, api_secret),
                  verify=False)
if r.status_code == 200:
    print("Request succesful %s"%r.text)
else:
    print("Request failed with status code %s" % r.status_code)
print("Response: %s" % r.text)
    