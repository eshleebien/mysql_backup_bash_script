#!/bin/bash
SHELL=/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin 
declare -a databases=('db1' 'db2');
db_username="username"
db_password="password"


date_today=$(date)
SCRIPT=$(readlink -f "$0")
SCRIPTPATH=$(dirname "$SCRIPT")
LOGPATH=$SCRIPTPATH'/backup_log.txt'

echo "============ "+$date_today+"=========" >> $LOGPATH

max=${#databases[@]}
echo 'number of DB to backup '$max

for ((i=0; i<max; i++))
do
    started_date=$(date +"%m-%d-%y")'_'$(date +"%T")
    filename=$SCRIPTPATH'/'${databases[$i]}'_'$started_date'.sql'
    echo $filename
    sudo mysqldump -u$db_username -p$db_password ${databases[$i]} > $filename
    retval=$?
    echo $retval
    if [ $retval -eq 0 ]; then
        end_date=$(date +"%m-%d-%y")'_'$(date +"%T")
        echo "${databases[$i]} backup success : $end_date" >> $LOGPATH
    else
        end_date=$(date +"%m-%d-%y")'_'$(date +"%T")
        echo "${databases[$i]} backup error $retval : $end_date" >> $LOGPATH
    fi
done
