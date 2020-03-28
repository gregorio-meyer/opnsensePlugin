#!/usr/bin/env python3.7
import re


class Connection:
    def __init__(self, ip, direction, last2s, last10s, last40s, cumulative):
        self.ip = ip
        self.direction = direction
        self.last2s = last2s
        self.last10s = last10s
        self.last40s = last40s
        self.cumulative = cumulative

    def __repr__(self):
        return str(self)

    def __str__(self):
        return "\n-------------------------\nIp: " + self.ip + "\nDirection "+self.direction+"\nLast 10s: "+str(self.last10s)+"\nLast 2s: "+str(self.last40s)+"\nLast 40s: "+str(self.last40s) + "\nCumulative "+str(self.cumulative)+"\n"

    def isActive(self):
        active = 0
        if self.last2s > 0:
            active += 1
        if self.last10s > 0:
            active += 1
        if self.last40s > 0:
            active += 1
        if self.cumulative > 0:
            active += 1
        return active > 3


class Report:
    def __init__(self, connections_in, connections_out):
        self.connections_in = connections_in
        self.connections_out = connections_out

    def __str__(self):
        return "Connections in " + str(self.connections_in) + "\n Connections out " + str(self.connections_out)

    def isConnected(self, ip):
        active = 0
        for connection in self.connections_in:
            if(connection.ip == ip):
                if connection.isActive():
                    active += 1
                    if active >= 5:
                        return True
        # not useful when looking for an active host
        # for connection in self.connections_out:
        #     if connection.isActive():
        #         active += 1
        #     if active >= 5:
        #         return True
        return False


def getFloat(string):
    f = None
    try:
        f = float(string)
    except Exception as e:
        print(e)
    return f


def removeLetters(string):
    s = ''
    for letter in string:
        if not letter.isalpha():
            s += letter
    string = s
    return string


def getDirection(string):
    if string != "=>" and string != "<=":
        raise SyntaxError("Wrong direction")
    return "out" if string == "=>" else "in"

# i could convert everything in bytes


def getValue(string):
    return getFloat(removeLetters(string))


def parseConnections(lines, start):
    connections = []
    for line in lines:
        connection = Connection(line[start], getDirection(line[start+1]), getValue(
            line[start+2]), getValue(line[start+3]), getValue(line[start+4]), getValue(line[start+5]))
        connections.append(connection)
    return connections


def getConnections(lines):
    i = -1
    result = []
    for line in lines:
        if line.startswith("-"):
            i = 0
        if line.startswith("Total send rate:"):
            break
        if i >= 0:
            if i > 0:
                # print("Line: %s content: %s" % (i, line))
                result.append(line)
            i += 1
    print("Got interesting lines length: "+len(lines))
    connections_out = []
    connections_in = []
    for line in result:
        # if line number is first digit
        if len(line) < 4:
            print("Error line too short "+line)
            exit(0)
        if line[3].isdigit():
            connections_out.append(line.split())
        else:
            connections_in.append(line.split())
    return connections_in, connections_out


def getReport(lines):
    connections_in, connections_out = getConnections(lines)
    print("Got connections ")
    return Report(parseConnections(connections_in, 0),
                  parseConnections(connections_out, 1))


def parse(lines):
    return getReport(lines)
