#!/bin/bash
IP=
DBUser=
DBPasswd=

user[0]=

for line in ${user[@]}
do
  privi=$(echo $line | awk -F ";" '{print $1}')
  dbs=$(echo $line | awk -F ";" '{print $2}' | sed -e 's/|/\ /g')
  client_user=$(echo $line | awk -F ";" '{print $3}')
  ips=$(echo $line | awk -F ";" '{print $4}' | sed -e 's/|/\ /g')
  for db in $dbs
  do
    for ip in $ips
    do
      #echo "grant $privi on ${db}.* to ${client_user}@${ip};"
      mysql -u $DBUser -p$DBPasswd -e "grant $privi on ${db}.* to ${client_user}@${ip};"
    done
  done
done

exit 0;
