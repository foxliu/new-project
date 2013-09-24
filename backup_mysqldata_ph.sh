#!/bin/bash
#This is a ShellScript For Auto MysqlDB Backup
#By foxliu2012@gmail.com
#2013-9

#Setting
DBName=
DBUser=
DBPasswd=
BackupPath=
#Setting END

#progress
t=`date +%Y%m.%d`
y=`expr substr $t 1 4`
md=`expr substr $t 5 5`
backupdir=$(echo "$BackupPath" | sed -e 's/\/$//')/$y/$md

getbinlog () {
  echo -e "\n$(date +%Y%m%d-%H:%M) \t backup data ph \n ============================================" >> /$backupdir/binlog_from.log
  /usr/local/mysql/bin/mysql -u $DBUser -p$DBPasswd -S /tmp/mysql.sock -e "stop slave;" && /usr/local/mysql/bin/mysql -u$DBUser -p$DBPasswd -S /tmp/mysql.sock -e "show slave status\G" | grep -E '(Relay_Master_Log_File|Exec_Master_Log_Pos)' >> /$backupdir/binlog_from.log
}

backup_data () {
  /usr/local/mysql/bin/mysqldump -u $DBUser -p$DBPasswd -S /tmp/mysql.sock $DBName > $backupdir/"$DBName".sql && /usr/local/mysql/bin/mysql -u $DBUser -p$DBPasswd -S /tmp/mysql.sock -e "slave start;"
}

if [ ! -d $backupdir ]; then
  mkdir -p $backupdir
  (getbinlog && backup_data) && echo -e "\n===========================================\n$(date +%Y%m%d-%H:%M) \t Backup Complete" >> /$backupdir/binlog_from.log
else
  (getbinlog && backup_data) && echo -e "\n===========================================\n$(date +%Y%m%d-%H:%M) \tBackup Complete" >> /$backupdir/binlog_from.log
fi


find /data/mysqldata_ph -mindepth 2 -maxdepth 2 -type d -mtime +7 -exec rm -rf {} \;


