#!/bin/bash
User="$1"
Password="$2"
Ftpdir="$3"

check=$(grep ftpuser /etc/passwd)

if [ -z $check ]; then
  useradd -M -s /sbin/nologin ftpuser
else
  Uid=$(grep ftpuser /etc/passwd | cut -d ":" -f3)
  Gid=$(grep ftpuser /etc/passwd | cut -d ":" -f4)
fi

if [ -z $User ]; then
  echo "Enter the user name"
else
  checkuser=$(awk 'BEGIN{FS=":"}{print $1}' /etc/proftpd/ftpd.passwd | grep $User )
  if [ -z $checkuser ];then
    echo "The user name is not existed!"
  else
    if [ -z $Password ]; then
      Password="${User}forcfp"
    fi
    if [ -z $Ftpdir ]; then
      Ftpdir=/data/ftpdir/$User
    fi
    echo $Password | ftpasswd --stdin --passwd --name=$User --change-password --file=/etc/proftpd/ftpd.passwd 1>/dev/null
    echo ""
    echo "The user ${User}'s new password is ${Password}"
    echo ""
    exit 1
  fi
fi

exit 0
