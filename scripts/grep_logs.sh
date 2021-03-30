#!/bin/bash
if [ $# -lt 4 ]
then
  echo "Usage: ./grep_logs.sh <ssh_identity_file> <remote_user> <remote_host> <remote_path> [<remote_port>]"
  echo "Usual remote path: /var/log/suricata/"
else
  ssh_id=$1
  user=$2
  host=$3
  path=$4
  port=${5:-22}
  scp -i "$ssh_id" -P "$port" -r "$user@$host:$path" ./logs
fi