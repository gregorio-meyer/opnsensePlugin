#!/usr/bin/env python3.7
import requests
import json

# key + secret 
api_key = 'W7meYzZdEndQGBycVONls8cYU8FBGsnMNoirAwAplMtVz8c1g7M7eR89HJcZaGXfT0i+KwcPpfAwBdy2'
api_secret = 't7BuWrgGciJeMp3hatlofJ4JufoWtDDwHc3XuZGxC28ratSvZzqLmH+yslZB1YbLk0KXJVXdYJGunS0W'
url = "http://10.0.0.5/api/automaticshutdown/settings/get"

r = requests.get(url, auth=(api_key, api_secret),
                  verify=False)
if r.status_code == 200:
    response = json.loads(r.text)
    address = response['automaticshutdown']['addresses']['address']
    if len(address) > 0:
        print("Shutdown planned between %s and %s" % (address['StartHour'], address['EndHour']))
    else:
        print("No shutdown planned")
else:
    print("Request failed with status code %s" % r.status_code)
    