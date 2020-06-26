#!/bin/bash
#set -x
##################################################################################################################################
##################################################################################################################################
####                           This script takes stream name as input and checks the corresponding autosys jobs               ####
####                                     Author : Kamal Ranjan Sahoo                                                          ####
####                                     Creation Date : 07-MAR-2020                                                          ####
##################################################################################################################################
##################################################################################################################################


################################################### Variable Declaration #########################################################

MY_HOME_PATH="/home/`whoami`"
stream=${1:-`echo 'gdsldn'`}
STREAM=`echo $stream | tr a-z A-Z`
BOX=`echo flm.ldn.prd.ecp.lri.${stream}.box.lp1`
TIME=`autorep -j $BOX -l0 |  sed -n '4p' | awk '{print $4, $5}'`
START_DATE=`autorep -j $BOX -l0 | sed -n '4p' | awk '{print $2}'`
CURR_DAY=`date +'%d/%m/%Y'`
OUTFILE=`echo $$`_status.txt
FILE_PATH="/home/sahook/scripts/shell_scripts"

if [ `autostatus -j $BOX` == "SUCCESS" ]&&[ $CURR_DAY == $START_DATE ]
 then
  echo " $STREAM completed at $TIME" >> $MY_HOME_PATH/$OUTFILE
 elif [ $CURR_DAY != $START_DATE ]
  then
   { echo -e "\n ====================================================="; echo -e " $STREAM is `autostatus -j $BOX` for $START_DATE - Not Run for Today" ; echo " ====================================================";} >>  $MY_HOME_PATH/$OUTFILE
 else
  { echo -e "\n =========================="; echo -e " $STREAM is `autostatus -j $BOX`" ; echo " ===========================";} >>  $MY_HOME_PATH/$OUTFILE
  $FILE_PATH/ThreadJob_Dependency_Check.sh $BOX >> $MY_HOME_PATH/$OUTFILE
fi

cat $MY_HOME_PATH/$OUTFILE | awk '!x[$0]++'
rm -f  $MY_HOME_PATH/$OUTFILE
