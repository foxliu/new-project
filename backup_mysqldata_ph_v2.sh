#!/bin/bash
#This is a ShellScript For Auto MysqlDB Backup
#By foxliu2012@gmail.com
#2013-12

#Setting
DBNames="ph ph_click dzdata"
DBUser=root
DBHost=27.112.3.67
DBPasswd=zaq12wsxz
BackupPath=/data/mysqldata_ph
#Setting END

#progress
t=`date +%Y%m.%d`
y=`expr substr $t 1 4`
md=`expr substr $t 5 5`
backupdir=$(echo "$BackupPath" | sed -e 's/\/$//')/$y/$md

#Backup Method in rysnc and mysqldump

Backup_Method=rsync


getbinlog () {
  echo -e "\n$(date +%Y%m%d-%H:%M) \t backup data ph \n ============================================" >> /$backupdir/binlog_from.log
  /usr/local/mysql/bin/mysql -u $DBUser -p$DBPasswd -h $DBHost -e "stop slave;" && /usr/local/mysql/bin/mysql -u$DBUser -p$DBPasswd -h $DBHost -e "show slave status\G" | grep -E '(Relay_Master_Log_File|Exec_Master_Log_Pos)' >> /$backupdir/binlog_from.log
}

backup_data () {
  case $Backup_Method in
    mysqldump )
      /usr/local/mysql/bin/mysqldump -u $DBUser -p$DBPasswd -h $DBHost  $DBName > $backupdir/"$DBName".sql
	;;
    rsync )
      rsync -aqzP root@$DBHost:/usr/local/mysql/data/$DBName $backupdir
	;;
    * )
      echo "Set Backup_Method=rsync or mysqldump"
	;;
  esac
}

dump_innodb_table () {
  tables=$(mysql -u $DBName -p$DBPasswd -h $DBHost -e "select table_name, engine from information_schema.tables where table_schema='ph' and engine='InnoDB'\G" | grep table_name | awk '{print $2}')
  for table in $tables
  do
    /usr/local/mysql/bin/mysqldump -u $DBUser -p$DBPasswd -h $DBHost ph $table > $backupdir/${table}.sql
  done
}

if [ ! -d $backupdir ]; then
    mkdir -p $backupdir
fi

getbinlog

for DBName in $DBNames
do
  backup_data
done

dump_innodb_table

/usr/local/mysql/bin/mysql -u $DBUser -p$DBPasswd -h $DBHost -e "slave start;"
echo -e "\n===========================================\n$(date +%Y%m%d-%H:%M) \tBackup Complete" >> /$backupdir/binlog_from.log

#delete 2 days ago's backup file

find /data/mysqldata_ph -mindepth 2 -maxdepth 2 -type d -mtime +6 -exec rm -rf {} \;


