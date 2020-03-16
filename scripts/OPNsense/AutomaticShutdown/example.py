#!/usr/bin/env python3.7
print("Program starts...")
import requests
import json
# key + secret from downloaded apikey.txt
api_key = 'W7meYzZdEndQGBycVONls8cYU8FBGsnMNoirAwAplMtVz8c1g7M7eR89HJcZaGXfT0i+KwcPpfAwBdy2'
api_secret = 't7BuWrgGciJeMp3hatlofJ4JufoWtDDwHc3XuZGxC28ratSvZzqLmH+yslZB1YbLk0KXJVXdYJGunS0W'

# define the basics, hostname to use and description used to identify our test rule
rule_description='OPNsense_fw_api_testrule_1'
remote_uri="https://10.0.0.5"

print("Done");