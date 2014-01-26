#!/bin/bash
export LANG=en_US.UTF-8

# Setting
FILE=''
THRESHOLD=
Load_thre=

# check the load is warn or not, if the load < threshold , exit the progress
load_average=$(uptime | awk '{print $(NF-2)}' | sed -e 's/,//g')
load_check=$(awk -v now=$load_average -v thre=$Load_thre 'BEGIN{print(now >= thre)?"1":"0"}')
if [ "$load_check" -eq 0 ]; then
    exit 0
fi

# get the file and path
DATE=$(date "+%Y%m%d%H")
Y=$(expr substr $DATE 1 4)
M=$(expr substr $DATE 5 2)
D=$(expr substr $DATE 7 2)
H=$(expr substr $DATE 9 2)
File=/var/log/apache2/$Y/$M/$D/${FILE}_${H}-access_log

# get Less than 10 minutes which ip's accesses is more than Threshold 
date_10min_ago=$(date --date="10 minutes ago" "+%Y:%H:%M:%S")
date_now=$(date "+%Y:%H:%M:%S")
for ip in $(cat $File | sed -n "/$date_10min_ago/,/$date_now/ p"| awk -v count=$THRESHOLD '{a[$1]++}END{for (i in a) if (a[i] > count) print i}')
do
    # deny ip to access and check the ip was denied or not
    ufw status | grep $ip | grep DENY
    if [ $? -ne 0 ]; then
	echo "$date_now  $ip > $THRESHOLD defense" >> /var/log/defense_down.log
	ufw insert 1 deny from $ip to any
    fi
done

exit 0
