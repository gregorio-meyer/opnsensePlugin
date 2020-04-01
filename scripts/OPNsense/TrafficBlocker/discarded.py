
# def checkIftop(ip):
#     print("Trying to make iftop call")
#     result = ping(ip)
#     print("Ping result ", result)
#     try:
#         p = subprocess.check_output("iftop -i em1 -t -s 1", stderr=subprocess.STDOUT,
#                                     shell=True)
#     except subprocess.CalledProcessError as e:
#         print(e.output)
#         print('Error running command: ' + '"' +
#               e.cmd + '"' + ' see above shell error')
#         print('Return code: ' + str(e.returncode))
#     # a byte object is returned
#     result = str(p.decode("ascii")).split('\n')
#     r = parse(result)
#     # print("Report: ", r)
#     connected = r.isConnected(ip)
#     print("Connected: ", connected)
#     threading.Timer(1, checkIftop, [ip]).start()


# def checkPing(ip):
#     if not ping(ip):
#         global locked
#         # if not locked lock
#         if not locked:
#             print("Not locked, lock")
#             blockTraffic(True)
#             locked = True
#             # if the connection is already locked continue
#         print("Already locked")
#     else:
#         # if locked unlock
#         if locked:
#             print("Locked, unlock")
#             blockTraffic(False)
#             locked = False
#         print("Already unlocked")
#     threading.Timer(1, checkPing, [ip]).start()


# attempts = 0


# def check(ip):
#     # check for
#     if not isConnected(ip):
#         global attempts
#         global locked
#         attempts += 1
#         print("Attempts %s" % attempts)
#         # number of connection checks before disabling connection
#         if attempts > 10:
#             attempts = 0
#             # if not locked lock
#             if not locked:
#                 print("Not locked, lock")
#                 blockTraffic(True)
#                 locked = True
#             # if the connection is already locked continue
#             print("Already locked")
#     else:
#         attempts = 0
#         # if locked unlock
#         if locked:
#             print("Locked, unlock")
#             blockTraffic(False)
#             locked = False
#         print("Already unlocked")
#     threading.Timer(1, check, [ip]).start()

# check connection with arp api


# def isConnected(ip):
#     connected = False
#     r = requests.post(url+"api/diagnostics/interface/flushArp",
#                       auth=(api_key, api_secret), verify=False)
#     time.sleep(1)
#     r = requests.get(url+"api/diagnostics/interface/getArp",
#                      auth=(api_key, api_secret), verify=False)

#     if r.status_code == 200:
#         response = json.loads(r.text)
#         # check if there is a client with that ip on the monitored interface
#         for host in response:
#             if host["ip"] == ip:
#                 interface = host["intf_description"]
#                 # print(host)
#                 if interface == monitored_intf:
#                    # print("Host is connected on %s" % interface)
#                     connected = True
#     else:
#         print("Request failed with error code %s" % r.status_code)
#     return connected


# def ping(ip):
#     # ping host t = timeout  S= source address
#     result = os.system("ping -S " + firewall_ip+" -t 2 -c 3 " + ip)
#     return True if result == 0 else False
#=====================================================================================
##!/usr/bin/env python3.7
# import re


# class Connection:
#     def __init__(self, ip, direction, last2s, last10s, last40s, cumulative):
#         self.ip = ip
#         self.direction = direction
#         self.last2s = last2s
#         self.last10s = last10s
#         self.last40s = last40s
#         self.cumulative = cumulative

#     def __repr__(self):
#         return str(self)

#     def __str__(self):
#         return "\n-------------------------\nIp: " + self.ip + "\nDirection "+self.direction+"\nLast 10s: "+str(self.last10s)+"\nLast 2s: "+str(self.last40s)+"\nLast 40s: "+str(self.last40s) + "\nCumulative "+str(self.cumulative)+"\n"

#     def isActive(self):
#         active = 0
#         if self.last2s > 0:
#             active += 1
#         if self.last10s > 0:
#             active += 1
#         if self.last40s > 0:
#             active += 1
#         if self.cumulative > 0:
#             active += 1
#         print("Active ",active)
#         return active > 3


# class Report:
#     def __init__(self, connections_in, connections_out):
#         self.connections_in = connections_in
#         self.connections_out = connections_out

#     def __str__(self):
#         return "Connections in " + str(self.connections_in) + "\n Connections out " + str(self.connections_out)

#     def isConnected(self, ip):
#         active = 0
#         for connection in self.connections_in:
#             if(connection.ip == ip):
#                 if connection.isActive():
#                     active += 1
#                     if active >= 2:
#                         return True
#         print("Active connections: ",active)
#         # not useful when looking for an active host
#         # for connection in self.connections_out:
#         #     if connection.isActive():
#         #         active += 1
#         #     if active >= 5:
#         #         return True
#         return False


# def getFloat(string):
#     f = None
#     try:
#         f = float(string)
#     except Exception as e:
#         print(e)
#     return f


# def removeLetters(string):
#     s = ''
#     for letter in string:
#         if not letter.isalpha():
#             s += letter
#     string = s
#     return string


# def getDirection(string):
#     if string != "=>" and string != "<=":
#         raise SyntaxError("Wrong direction")
#     return "out" if string == "=>" else "in"

# # i could convert everything in bytes


# def getValue(string):
#     return getFloat(removeLetters(string))


# def parseConnections(lines, start):
#     connections = []
#     for line in lines:
#         connection = Connection(line[start], getDirection(line[start+1]), getValue(
#             line[start+2]), getValue(line[start+3]), getValue(line[start+4]), getValue(line[start+5]))
#         connections.append(connection)
#     return connections


# def getConnections(lines):
#     i = -1
#     result = []
#     for line in lines:
#         if line.startswith("-"):
#             i = 0
#         if line.startswith("Total send rate:"):
#             break
#         if i >= 0:
#             if i > 0:
#                 # print("Line: %s content: %s" % (i, line))
#                 result.append(line)
#             i += 1
#     print("Got interesting lines length: ", len(result))
#     if len(result) == 0:
#         return [], []
#     i = 0
#     for line in result:
#         print(line, i)
#         i += 1
#     connections_out = []
#     connections_in = []
#     for line in result:
#         # print(line)
#         # if line number is first digit
#         # if len(line) > 4:
#         if line[3].isdigit():
#             connections_out.append(line.split())
#         else:
#             connections_in.append(line.split())

#     return connections_in, connections_out


# def getReport(lines):
#     for line in lines:
#         print(line)
#     # exit(0)
#     connections_in, connections_out = getConnections(lines)
#     print("Got connections in %s out %s " %
#           (len(connections_in), len(connections_out)))
#     return Report(parseConnections(connections_in, 0),
#                   parseConnections(connections_out, 1))


# def parse(lines):
#     return getReport(lines)
#=====================================================================================
# from subprocess import check_call
# import sys
# def stop():
#     print("Stopping traffic blocker..")
#     script = "blockWifiIp.py"
#     try:
#       check_call(["pkill", "-9", "-f", script])
#     except Exception as e:
#         print("Failed:%s" % e)

# stop()