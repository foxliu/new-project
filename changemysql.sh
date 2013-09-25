#!/bin/bash
#Setting
Logfile=
Databses=" "
Backfile_dir=
Mysqldir=

Realbackdir=$(sed 's/\/$//' $Backfile_dir)
Backupdata () {
  for i in $Databases
  do
    mysqldump -S /tmp/mysqld.sock --opt --database $i > "$Realbackdir"/"$i" && mysql -S /tmp/mysql.sock < "$Realbackdir"/"$i"
  done
}

Stopmysql () {
  netstat -tlunp | grep '3309' | awk '{print $7}' | sed 's/\/.*$//g' | xargs kill
  /etc/init.d/mysql stop
}

Changefile () {
  [ -L /usr/local/mysql ] || rm -f /usr/local/mysql && ln -s $Mysqldir /usr/local/mysql
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
