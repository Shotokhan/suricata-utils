#!/bin/bash
# make sure you have NFQ in your build
# suricata --build-info
sudo iptables -I INPUT -j NFQUEUE
sudo iptables -I OUTPUT -j NFQUEUE
# to make sure everything is well, check if Suricata is running and type:
# sudo iptables -vnL
sudo suricata -c /etc/suricata/suricata.yaml -q 0 -D
sleep 10  # set this value properly according to suricata bootstrap time on your machine
sudo ./check_suricata_run_reset_fw.sh
