#! /bin/bash
#set -x
##################################################################################################################################
##################################################################################################################################
####                           This script helps checking the current state and dependencies of a given autosys box           ####
####                                     Author : Kamal Ranjan Sahoo                                                          ####
####                                     Creation Date : 21 AUG 2019                                                          ####
##################################################################################################################################
##################################################################################################################################

JOB=$1
CUR_STATUS=`autostatus -j $JOB`

if [ $CUR_STATUS == "ON_HOLD" ]||[ $CUR_STATUS == "INACTIVE" ]||[ $CUR_STATUS == "TERMINATED" ]||[ $CUR_STATUS == "FAILURE" ]
then
        printf " $JOB is in $CUR_STATUS state\n Check the reason\n"
elif [  $CUR_STATUS == "RUNNING" ]
then
 printf " Because --->\n"
#  printf "\n*******Let\'s take a look at the jobs inside the box******* \n"
  for JB in `autorep -j $JOB  |  awk '{print $1}' | sed '1,4d;$d'`
    do
      CUR_CHLD_STATUS=`autostatus -j $JB`
      if [ $CUR_CHLD_STATUS == "ON_HOLD" ]||[ $CUR_CHLD_STATUS == "TERMINATED" ]||[ $CUR_CHLD_STATUS == "FAILURE" ]
      then
        printf "\nPlease check $JB : It is in $CUR_CHLD_STATUS state\n"
      else
        JOB_TYPE=`autorep -j $JB -q | sed -n '3p' | awk '{print $NF}'`
            if  [ $JOB_TYPE == "CMD" ]&&[ $CUR_CHLD_STATUS == "RUNNING" ]
            then
               printf "$JB  $CUR_CHLD_STATUS\n"
               printf "Stream and Machine : `autorep -qj $JB -l0| grep -e "^command:" -e "^machine:"  | awk '{print $NF}' | paste -s -d " "`\n"
            elif [ $JOB_TYPE == "CMD" ]&&[ $CUR_CHLD_STATUS == "ACTIVATED" ]
            then
#               printf "\nOther jobs in side the box are dependent on the completion of below jobs\n"
#               printf "\n$JB ACTIVATED: Its upstream job(s) not SUCCESS.\n"
               job_depends -cj $JB | grep -A4 "Atomic Condition" | awk '{if ($NF == "F") {print $1, $2}}' | awk -F'[()]' '{print $2, $3}' | grep -vw "ACTIVATED"
            fi
      fi
    done
fi
