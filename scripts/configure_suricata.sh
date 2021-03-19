#!/bin/bash
# cd /etc/suricata
# curl -O https://rules.emergingthreatspro.com/open/suricata/emerging.rules.tar.gz
# tar xzvf emerging.rules.tar.gz
# ln -s /etc/suricata/rules/reference.config /etc/suricata/reference.config
# ln -s /etc/suricata/rules/classification.config /etc/suricata/classification.config
# cp /etc/suricata/rules/suricata-1.2-prior-open.yaml /etc/suricata/suricata.yaml
sudo suricata-update
