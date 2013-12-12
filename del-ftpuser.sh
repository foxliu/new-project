#!/bin/bash
User="$1"
Ip="$2"

ftpasswd --delete-user --name=$User --passwd --file=/etc/proftpd/ftpd.passwd >/dev/null || (echo "The user $User is not existed!" ; exit 1 ) && echo "The user $User is deleted!"
