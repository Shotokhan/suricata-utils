#!/bin/bash
sudo suricata -c /etc/suricata/suricata.yaml -q 0 -D
sudo iptables-apply -t 30 nfq_drop.rules
