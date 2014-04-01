#!/bin/bash
MKFIFO='/usr/bin/mkfifo'
TEMP_FIFO=/tmp/$$.fifo
FAILURE_FLAG=/var/log/failure.log

functions trap_exit
{
    kill -9 0
}
exec_cmd() {
    rsync -av 219.239.94.111:${1}/${2} ${1}/
    if [ $? -ne 0 ]; then
        echo "command execute failure"
        return 1
    fi
}

trap 'trap_exit; exit 2' 1 2 3 15

$MKFIFO $TEMP_FIFO
exec 6<>$TEMP_FIFO
rm -f $TEMP_FIFO

{
    for (i=1;i<=4;i++)
    do
        echo
    done
} >&6

while read SEC
do
    read <&4
    ( exec_cmd $PATH_MID ${SEC} || echo ${SEC}>>${FAILURE_FLAG}) &
    ( exec_cmd $PATH_UPLOAD $SEC || echo ${SEC}>>${FAILURE_FLAG} ; echo >&6 ) &
done < $CMD_CFG

wait

exec 4>&-

if [ -f ${FAILURE_FLAG} ]; then
    exit 1
else
    exit 0
fi

