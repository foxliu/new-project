#!/bin/bash
# Author: Juniper Liu
# Date: 2014-04-01
# To quick rsync the pciture file

PATH_IMG=/bank/bank10/img14/midimg
PATH_UPLOAD=/bank/bank10/img14/uploadimg

SRC_IMG=/data/img14/midimg
SRC_UPLOAD=/data/img14/uploadimg

LOGFILE=/root/uploadimg.log
NEW_LOG=/root/uploadimg_new.log

LS='/bin/ls'
SED='/bin/sed'
DIFF='/usr/bin/diff'
RSYNC='/usr/bin/rsync'
MKFIFO='/usr/bin/mkfifo'

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
	for (i=1;i<=4;i++)
	do
		echo
	done
}>&6

