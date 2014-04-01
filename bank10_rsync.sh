#!/bin/bash
LOCKFILE=/tmp/$(basename $0)_lockfile
SCRIPT=/opt/bin/bank_rsync.sh

if [ -f $LOCKFILE ]; then
    MYPID=$(cat $LOCKFILE)
    ps -p $MYPID | grep $MYPID &>/dev/null
    [ $? -eq 0 ] && echo "The script $(basename $0) is running" && exit 1
else
    echo $$ > $LOCKFILE
fi
bash $SCRIPT
rm -f $LOCKFILE
exit 0
