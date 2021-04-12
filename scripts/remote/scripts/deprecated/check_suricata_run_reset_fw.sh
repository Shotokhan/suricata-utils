#!/bin/sh
status=$(sudo suricatasc -c uptime | grep -c '"return": "OK"')
if [ $status -eq 0 ] 
	then
	sudo iptables -F
fi
