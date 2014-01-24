#!/bin/bash
DBuser=root
DBpass=zaq12wsxz
DBip="219.239.94.108 27.112.3.76"
VIP=219.239.94.117
MYSQL='/usr/local/mysql/bin/mysql'
PING='/bin/ping'
IFCONFIG='/sbin/ifconfig'
Slave_master=219.239.94.106

$IFCONFIG | grep $VIP >/dev/null 2>&1
if [ "$?" == 0 ]; then
    echo "The Mysql Master Service is Localhost ! Don't execute $0 on this service"
    exit 0
fi

# Get Master info
Master_Info=$($MYSQL -u$DBuser -p$DBpass -e "show master status\G" | grep -E '(File|Position)')
log_file=$(echo $Master_Info | grep File | awk '{print $2}')
log_pos=$(echo $Master_Info | grep Position | awk '{print $4}')

# Check the VIP is or not alive
$PING $VIP -c 5 -w 5 >/dev/null 2>&1  && if [ "$?" == 0 ]; then
echo -e "Error!!!\nThe ip $VIP is aliving on $Slave_master\nFor remove it use ssh $Slave_master -f \"ip addr del 219.239.94.117/24 dev eth0\" \nAnd retry $0\n"
exit 0
fi

# Wait the Slave's synchronization is complete
Get_slave_behind_master_second () {
  $MYSQL -u$DBuser -p$DBpass -e "show slave status\G" | grep Seconds_Behind_Master | awk '{print $2}'
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

