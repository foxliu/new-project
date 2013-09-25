#!/bin/bash
#Database=$(ls /usr/local/mysql/data/ | grep \/ | grep -Ev '(bak|performance)')

for i in mysql cfp_swap crm2 crm4 test
do
  mysqldump -S /tmp/mysqld.sock --opt --database $i > /data/sql/$i && mysql -S /tmp/mysql.sock < /data/sql/$i
done

