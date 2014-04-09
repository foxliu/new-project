#!/bin/bash
# Author: Juniper Liu
# Date: 2014-04-01
# To quick rsync the pciture file

PATH_IMG=/bank/bank10/img14/midimg
PATH_UPLOAD=/bank/bank10/img14/uploadimg

SRC_IMG=/data/img14/midimg
SRC_UPLOAD=/data/img14/uploadimg

LOGFILE=/root/uploadimg1.log
NEW_LOG=/root/uploadimg_new1.log

LS='/bin/ls'
SED='/bin/sed'
DIFF='/usr/bin/diff'
RSYNC='/usr/bin/rsync'
MKFIFO='/usr/bin/mkfifo'

function trap_exit
{
	kill -9 0
}

exec_commod() {
	rsync -av 219.239.94.111:${1}/${2} ${1}/
	if [ $? -ne 0 ]; then
        echo "command execute failure"
        return 1
    fi
}

########################Script start#########################
FAILURE_FLAG=/var/log/failure.log
trap 'trap_exit; exit2' 1 2 3 15

$LS $PATH_UPLOAD > $LOGFILE
$LS $SRC_UPLOAD > $NEW_LOG

TEMP_FILE=/tmp/.rsync_file
TEMP_FIFO=/tmp/.$$_fifo

A=$($SED -n '$=' $LOGFILE)
$SED -i "$(($A-5+1)),${A}d" $LOGFILE
$DIFF $LOGFILE $NEW_LOG | $SED -e 's/^>\ //g' > $TEMP_FILE

$MKFIFO $TEMP_FIFO
exec 6<>$TEMP_FIFO
rm -f $TEMP_FIFO
{
	for ((i=1;i<=3;i++))
	do
		echo
	done
}>&6

path_img=$(echo $PATH_IMG | sed -e 's/\/$//')
path_upload=$(echo $PATH_UPLOAD | sed -e 's/\/$//')

while read SEC
do
	read <&6
	( exec_commod $path_img $SEC || echo $SEC >> $FAILURE_FLAG )&
	( exec_commod $path_upload $SEC || echo $SEC >> $FAILURE_FLAG ; echo >&6 )&
done <$TEMP_FILE

wait

exec 6>&-

rm -f $TEMP_FILE
rm -f $LOGFILE
rm -f $NEW_LOG

if [ -f $FAILURE_FLAG ];then
	exit 1
else
	exit 0
fi
