#!/bin/bash
export LANG=en.US_UTF-8

# Setting
DBuser=
DBpass=
Slaves=""
VIP=
Slave_master=

# Get the path of the progress which is needed
MYSQL="$(which mysql) -u$DBuser -p$DBpass"
PING="$(which ping)"
IFCONFIG="$(which ifconfig)"
IP="$(which ip)"

# Check the local service is the mysql master or not
$IFCONFIG | grep $VIP >/dev/null 2>&1
if [ "$?" == 0 ]; then
    echo "The Mysql Master Service is Localhost ! Don't execute $0 on this service"
    exit 0
fi

# Check the VIP is or not alive
$PING $VIP -c 5 -w 5 >/dev/null 2>&1  && if [ "$?" == 0 ]; then
echo -e "Error!!!\nThe ip $VIP is aliving on $Slave_master\nFor remove it use ssh $Slave_master -f \"ip addr del 219.239.94.117/24 dev eth0\" \nAnd retry $0\n"
exit 0
fi

# Wait the Slave's synchronization is complete
Get_slave_behind_master_second () {
    if [ -z $1 ]; then
        $MYSQL -e "show slave status\G" | grep Seconds_Behind_Master | awk '{print $2}'
    else
        $MYSQL -h $1 -e "show slave status\G" | grep Seconds_Behind_Master | awk '{print $2}'
    fi
}
if [ "$(Get_slave_behind_master_second)" = "NULL" ]; then
  echo "This Mysql service is not synchrond from Mysql master. Try other service , or try use $MYSQL -u <user> -p and enter start slave; Try again"
  exit 0
fi
while [ "$(Get_slave_behind_master_second)" != "0" ]
do
  echo "Wait the Slavs synchrond is completed...."
  sleep 1
done

# Change Local service to Mysql master
$MYSQL -e "stop slave;"
# Get Master info
Master_Info=$($MYSQL -e "show master status\G" | grep -E '(File|Position)')
log_file=$(echo $Master_Info | grep File | awk '{print $2}')
log_pos=$(echo $Master_Info | grep Position | awk '{print $4}')
# Add VIP on local service
$IP addr add ${VIP}/24 broadcast + dev eth0 label eth0:1

# Change the master info on slave service
for slave in $Slaves
do
    # check the slave is or not behind the master
    while [ "$(Get_slave_behind_master_second $slave)" != "0" ]
    do
        echo "Wait the Slave $slave is synchronding...."
        sleep 1
    done
    # stop slave and change master info restart the slave
    $MYSQL -h $slave -e "stop slave;"
    $MYSQL -h $slave -e "change master to master_host=${VIP}, master_user='bak43ph', master_password='comphoto', master_log_file=${log_file}, master_log_pos=${log_pos};"
    $MYSQL -h $slave -e "start salve;"
done

exit 0
