#!/bin/bash
Logfile=/root/tools/change.log

Backupdata () {
  for i in mysql cfp_swap crm2 crm4 test
  do
    mysqldump -S /tmp/mysqld.sock --opt --database $i > /data/sql/$i && mysql -S /tmp/mysql.sock < /data/sql/$i
  done
}

Stopmysql () {
  netstat -tlunp | grep '3309' | awk '{print $7}' | sed 's/\/.*$//g' | xargs kill
  /etc/init.d/mysql stop
}

Changefile () {
  rm -f /usr/local/mysql && ln -s /usr/local/mysql-5.1.30-linux-x86_64-glibc23 /usr/local/mysql
}

echo -e "==============Change Start===============" >> $Logfile 
Backupdata >> $Logfile
Stopmysql >> $Logfile
while [ "$(netstat -tlunp | grep -E '(3306|3309)')" != "" ]
do
  Stopmysql >> $Logfile
done
Changefile  >> $Logfile
/etc/init.d/mysql start >>$Logfile 
echo -e "\n==================Change Complete============="
