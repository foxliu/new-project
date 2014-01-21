#!/bin/bash
USER[0]=

USERADD='/usr/sbin/useradd'
PASSWD='/usr/bin/passwd'

for users in ${USER[@]}
do
  user=$(echo $users | awk -F";" '{print $1}')
  pass=$(echo $users | awk -F";" '{print $2}')
  
  $USERADD -g wheel $user && echo $pass | $PASSWD --stdin $user
  sleep 1
done



exit 0