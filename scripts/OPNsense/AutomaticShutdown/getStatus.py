#!/usr/bin/env python3.7
import requests
import json

# key + secret 
api_key = "71ubaqTIXb19HG7B17Yf3kG78FhkQC8lBDEmzSKV9gipNKh3rf1Ab52mfOpJ4j8cob6gPJU/T1EWYpfh"
api_secret = "OuLdyVHKrpvQ9dMyQ6D3VYEQTRTBDrPO8tNkiuGP8qMD4x1eu4MlEtvdeXhu6iC2sbTsVHCxDj7olNAy"
url = "http://10.0.0.5/api/automaticshutdown/settings/get"

r = requests.get(url, auth=(api_key, api_secret),
                  verify=False)
if r.status_code == 200:
    response = json.loads(r.text)
    hour = response['automaticshutdown']['hours']['hour']
    if len(hour) > 0:
        print("Shutdown planned between %s and %s" % (hour['startHour'], hour['endHour']))
    else:
        print("No shutdown planned")
else:
    print("Request failed with status code %s" % r.status_code)
    