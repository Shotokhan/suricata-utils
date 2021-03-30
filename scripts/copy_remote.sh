#!/bin/bash
if [ $# -lt 3 ]
then
  echo "Usage: ./copy_remote.sh <ssh_identity_file> <remote_user> <remote_host> [<remote_path>] [<remote_port>]"
else
  ssh_id=$1
  user=$2
  host=$3
  path=${4:-"/"}
  port=${5:-22}
  scp -i "$ssh_id" -P "$port" -r ./remote "$user@$host:$path"
fi