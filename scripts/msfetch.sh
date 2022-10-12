#!/bin/sh

set -e

if [ $# -ne 2 ]
then
    echo "Usage: `basename $0` <host> <database>"
    exit 65
fi

datestr=`date --iso-8601=minutes`
fname="$2-$datestr.sql"

# Ensure local dumps dir exists.
mkdir -p ~/dumps

# Execute mysqldump -uroot on the remote host.
echo "Dumping DB $2 on remote $1 to $fname (local and remote)..."
ssh -C $1 "mkdir -p ~/dumps && sudo mysqldump $2 | tee ~/dumps/$fname" > ~/dumps/$fname

# Execute ms -uroot on the local host.
echo "Loading DB $2 on local host..."
sudo mysql $2 < ~/dumps/$fname
