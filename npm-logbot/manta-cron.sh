#!/bin/bash

set -e
set -x

# put the log files in manta, because OBVIOUSLY
export MANTA_KEY_ID=55:5e:9a:bc:42:59:df:cb:ad:00:54:f6:59:53:20:83
export MANTA_USER=npm
export MANTA_URL=https://us-east.manta.joyent.com

. ~node/manta.env

id=$1
cmd="ls ~ubuntu/hosting/servers/isaacs/db/log/*.1"
d=$(date '+%Y-%m-%d')

for ip in $(dig +short isaacs.iriscouch.com | grep ^[0-9]); do
  for file in `ssh -i $id isaacs@$ip "$cmd"`; do
    gzfile=$(basename $file).gz
    ssh -i $id isaacs@$ip "cat $file | gzip" > $gzfile &&\
    mput -f $gzfile /npm/stor/logs/$d.$gzfile &&\
    rm -f $gzfile
  done
done
