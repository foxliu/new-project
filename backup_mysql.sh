#!/bin/bash
DBdata=""
DBdir=
DBuser=
DBpassword=
DBipaddr=

t=`date +%Y%m\.%d`
y=`expr substr $t 1 4`
md=`expr substr $t 5 5`
dbdir=$(echo $DBdir |sed 's/\/$//')
backdir=$dbdir/$y/$md
logfile=$dbdir/backup.log

dump_data () {
for i in $DBdata
do
  if [ -z $DBpassword ]; then
    /usr/local/mysql/bin/mysqldump -u$DBuser -h $DBipaddr $i > $backdir/$i.sql && echo -e "$(date +%Y%m%d) \t $i is complete ! " >> $logfile
  else
    /usr/local/mysql/bin/mysqldump -u$DBuser -p$DBpassword -h $DBipaddr $i > $backdir/$i.sql && echo -e "$(date +%Y%m%d) \t $i is complete ! " >> $logfile
  fi
done
}

if [ ! -d $backdir ]; then
	mkdir -p $backdir && dump_data
else
    dump_data
fi    

#delete 30 days ago file

find $dbdir -mindepth 2 -maxdepth 2 -type d -mtime +30 -exec rm -rf {} \;

exit 0  
