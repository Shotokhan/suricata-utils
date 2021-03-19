#!/bin/bash
PIDFILE=/var/run/suricata.pid
PID=$(cat $PIDFILE)
sudo kill -9 $PID 
sudo rm -f $PIDFILE
sudo iptables -F
