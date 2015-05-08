#!/bin/bash
SHELL=/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin

osname=`uname`
date_today=$(date)
script=${0}
scriptpath=$(dirname "$script")
logpath=$scriptpath'/backup_log.txt'

function HELP {
    echo "This is help"
    exit 1
}

# Getting required parameters
while getopts h:u:P:p:d:H opt; do
    case $opt in
        h)
            host=$OPTARG
            ;;
        u)
            username=$OPTARG
            ;;
        P)
            port=$OPTARG
            ;;
        p)
            password=$OPTARG
            ;;
        d)
            databases=$OPTARG
            ;;
        H)
            HELP
            ;;
        \?) #unrecognized option - show help
            echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed. "
            HELP
        esac
done
if [ -z "$username" ]; then
    echo -n 'Enter Administrative username : '
    read username

    if [ -z "$username" ]; then
        exit 0
    fi
fi

# Getting password
if [ -z "$password" ]; then
    echo -n 'Enter MySQL Password : '
    read -s password

    if [ -z "$password" ]; then
        echo
    fi
fi

if [ -z "$databases" ]; then
    echo 'Specify Database comma separated (-d) : '
    read databases
fi

# Convert comma separated string to array
IFS=', ' read -a databases <<< "$databases"

echo '============ '+$date_today+'=========' >> $logpath

max=${#databases[@]}

echo 'number of DB to backup '$max

for ((i=0; i<max; i++))
do
    started_date=$(date +'%m-%d-%y')'_'$(date +'%T')
    filename=$scriptpath'/'${databases[$i]}'_'$started_date'.sql'
    # echo $filename
    sudo mysqldump -h $host -u$username -p$password ${databases[$i]} > $filename
    retval=$?
    echo $retval
    if [ $retval -eq 0 ]; then
        end_date=$(date +'%m-%d-%y')'_'$(date +'%T')
        echo "${databases[$i]} backup success : $end_date" >> $logpath
    else
        end_date=$(date +'%m-%d-%y')'_'$(date +'%T')
        echo "${databases[$i]} backup error $retval : $end_date" >> $logpath
    fi
done

