#!/bin/bash
IP=
DBUser=
DBPasswd=

user[0]="select,update,insert,delete;ph|ph_click;photo;219.239.94.107|27.112.3.79"
user[1]="select,update,insert;ph;photo;219.239.94.110|219.239.94.118|219.239.94.121|219.239.94.126|27.112.3.79|27.112.3.69|192.155.87.118|106.187.93.177"
user[3]="select,update,insert,delete,create;ph ph_click;photo;219.239.94.123|219.239.94.115"
user[4]="select,update,insert;ph|ph_click;photo;219.239.94.112|219.239.94.113|219.239.94.114|27.112.3.78|27.112.3.76"

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