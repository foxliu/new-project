#!/bin/sh
/usr/bin/megacli -PDList -aALL > /tmp/mega.txt
diskNum=`cat /tmp/mega.txt | grep 'Inquiry Data' | wc -l`
offlineNum=`cat /tmp/mega.txt | grep 'Offline' | wc -l`
mediaErrNum=0
otherErrNum=0
a=`cat /tmp/mega.txt | grep 'Media Error Count' | awk -F ':' '{print $2}'`
for aa in $a;do
	if [ $aa -gt 0 ]; then
		#let mediaErrNum=$mediaErrNum+1
		mediaErrNum=`expr $mediaErrNum + 1`
	fi
done
b=`cat /tmp/mega.txt | grep 'Other Error Count' | awk -F ':' '{print $2}'`
for bb in $b;do
        if [ $bb -gt 0 ]; then
                #let otherErrNum=$otherErrNum+1
		otherErrNum=`expr $otherErrNum + 1`
        fi
done
echo $diskNum > /tmp/mega.status
echo $offlineNum >> /tmp/mega.status
echo $mediaErrNum >> /tmp/mega.status
echo $otherErrNum >> /tmp/mega.status
#echo $diskNum" "$offlineNum" "$mediaErrNum" "$otherErrNum
