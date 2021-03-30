#!/bin/bash
if [ $# -lt 4 ]
then
  echo "Usage: ./upload_rules.sh <ssh_identity_file> <remote_user> <remote_host> <remote_rules_path> [<remote_port>]"
  echo "Usual remote path: /var/lib/suricata/rules/ ; or: /etc/suricata/rules/"
else
  ssh_id=$1
  user=$2
  host=$3
  path=$4
  port=${5:-22}
  scp -i "$ssh_id" -P "$port" ./local.rules "$user@$host:$path"
  ssh -i "$ssh_id" -p "$port" "$user@$host" 'sudo suricatasc -c reload-rules'
fi