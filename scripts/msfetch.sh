#!/bin/sh

datestr=`date "+%m%d%Y-%H%M"`
fname="$2-$datestr.sql"

# Execute mysqldump -uroot on the remote host.
echo "Dumping DB $2 on remote $1 to $fname..."
ssh $1 "mkdir -p ~/dumps && mysqldump -uroot $2 > ~/dumps/$fname"

# scp file to local host.
echo "Downloading..."
mkdir -p ~/dumps
rsync -avz --progress $1:~/dumps/$fname ~/dumps/

# Execute ms -uroot on the local host.
echo "Loading DB $2 on local host..."
mysql -uroot $2 < ~/dumps/$fname
