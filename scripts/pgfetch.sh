#!/bin/sh

set -e

if [ $# -ne 2 ]
then
    echo "Usage: `basename $0` <host> <database>"
    exit 65
fi

host="$1"
dbname="$2"
username="$dbname"
datestr=`date --iso-8601=minutes`
fname="$dbname-$datestr.sql"

# Ensure local dumps dir exists.
mkdir -p ~/dumps

echo "Dumping DB $dbname on remote $host to $fname (local and remote)..."
ssh -C $1 "mkdir -p ~/dumps && sudo -u $username pg_dump $dbname | tee ~/dumps/$fname" > ~/dumps/$fname

echo "Dropping existing DB on local host..."
dropdb $dbname

echo "Creating new DB..."
createdb $dbname

echo "Loading DB dump..."
psql $dbname < ~/dumps/$fname

echo "Done"
