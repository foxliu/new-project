#!/bin/bash
# Author: Juniper Liu
# Date: 2014-04-01
# To quick rsync the pciture file

PATH_IMG=/bank/bank10/img14/midimg
PATH_UPLOAD=/bank/bank10/img14/uploadimg

# 获取文件目录的跟径
SRC_IMG=/data/img14/midimg
SRC_UPLOAD=/data/img14/uploadimg

NEW_LOG=/root/uploadimg_new2.log

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

$LS $SRC_UPLOAD > $NEW_LOG

TEMP_FIFO=/tmp/.$$_fifo

$MKFIFO $TEMP_FIFO
exec 8<>$TEMP_FIFO
rm -f $TEMP_FIFO
{
	for ((i=1;i<=3;i++))
	do
		echo
	done
}>&8

path_img=$(echo $PATH_IMG | sed -e 's/\/$//')
path_upload=$(echo $PATH_UPLOAD | sed -e 's/\/$//')

while read SEC
do
	read <&8
	( exec_commod $path_img $SEC || echo $SEC >> $FAILURE_FLAG )&
	( exec_commod $path_upload $SEC || echo $SEC >> $FAILURE_FLAG ; echo >&8 )&
done <$NEW_LOG

wait

exec 8>&-

rm -f $NEW_LOG

if [ -f $FAILURE_FLAG ];then
	exit 1
else
	exit 0
fi
