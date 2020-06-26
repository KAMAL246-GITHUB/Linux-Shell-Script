#!/bin/bash
#set -x
###################################################################################################################################
###################################################################################################################################
####     This script is designed to check autosys job status continuously and then send an email when the job is complete      ####
####                                 (Currently to be used for  Refresh only)                                                  ####
####                                        Author : Kamal Ranjan Sahoo                                                        ####
####                                        Creation Date : 30 Jul 2019                                                        ####
###################################################################################################################################
###################################################################################################################################

MAIL_LIST_USER="xyz@abc.com, def@abc.com"

#MAIL_LIST="xyz@abc.com, def@abc.com"

###  Publish the usage of the script to user in case no argument was given ##

if [ "$#" -eq 0 ]
then
    echo "USAGE: $0 <Autosys JOB Name to be Monitored>"
    exit
fi
ARG1="$1"


get_duration(){
 echo  "($(date +%s -d "$2") - $(date +%s -d "$1"))"/60 | bc
}


##########  Monitoring the job's status in a loop until the job goes to success   ##

STATUS=`autostatus -j "$ARG1"`
while [ "$STATUS" != "SUCCESS" ]
do
    sleep 5
    STATUS=`autostatus -j "$ARG1"`
done

set -- $(autorep -j "$ARG1" | tail -2 | head -1)
T1=$(echo $(echo $2 | awk -F'/' '{print $3"-"$2"-"$1"T"}')$3)
T2=$(echo $(echo $4 | awk -F'/' '{print $3"-"$2"-"$1"T"}')$5)
DURATION=$(get_duration "$T1" "$T2")

### Send Email to the prescribed recipients when the job is complete ###
printf "The requested  Refresh completed in $(echo $DURATION) Minutes.\nFor any Queries, please contact FRT production support\n\nThanks" | ma        ilx -s ' Refresh Status' $MAIL_LIST_USER

