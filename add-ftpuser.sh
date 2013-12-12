#!/bin/bash
User="$1"
Password="$2"
Ftpdir="$3"
Ip="$4"

MKDIR='/bin/mkdir'
FTPASSWD='/usr/sbin/ftpasswd'


check=$(grep ftpuser /etc/passwd)

if [ -z $check ]; then
  useradd -M -s /sbin/nologin ftpuser
else
  Uid=$(grep ftpuser /etc/passwd | cut -d ":" -f3)
  Gid=$(grep ftpuser /etc/passwd | cut -d ":" -f4)
fi

if [ -z $User ]; then
  echo "Please enter a user name!"
  read -p "Enter a user name: " User
fi

checkuser=$(awk 'BEGIN{FS=":"}{print $1}' /etc/proftpd/ftpd.passwd | grep ${User})

if [ ! -z $checkuser ];then
  echo "The user name is existed!"
else
  if [ -z $Password ]; then
    Password="${User}forcfp"
  fi
  if [ -z $Ftpdir ]; then
    Ftpdir=/data/ftpdir/$User
  fi
  if [ ! -d $Ftpdir ]; then
    $MKDIR -p $Ftpdir
  fi
  chown -R ${Uid}.${Gid} $Ftpdir
  echo $Password | $FTPASSWD --stdin --passwd --name=$User --uid=$Uid --gid=$Gid --home=$Ftpdir --file=/etc/proftpd/ftpd.passwd --shell=/sbin/nologin 1>/dev/dull
  echo ""
  echo "The new user is created"
  echo "User name is: $User"
  echo "Password is: $Password"
  echo ""
  exit 1
fi

exit 0
