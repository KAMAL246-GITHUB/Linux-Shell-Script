#!/bin/ksh
set -x
GetLastBusinessDay()
{
        set -A MONTHS Dec Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
        BACK=$1
        THEN=$((`date +%d` - $BACK))
        MONTH=`date +%m`
        YEAR=`date +%y`
        WEEKDAY=${DAYS[`date +%u`]}
        if [ $THEN -le "0" ]
        then
                MONTH=0$((MONTH-1))
                if [ $MONTH -eq "0" ]
                then
                        MONTH=12
                        YEAR=$((YEAR-1))
                fi
                set `cal $MONTH $YEAR`
                SHIFT=$(( $THEN * -1 + 1 ))
                shift $(($# - $SHIFT))
                THEN=$1
        fi
        TMONTH=${MONTHS[MONTH]}

        DNUM=`echo $THEN | awk '{gsub(/\<[0-9]\>/, "0&", $1)}1'`
        #echo $DNUM

        OUTPUTDATE=${DNUM}-${MONTH}-${YEAR}
        #echo $OUTPUTDATE

        DATEOUTPUT=20${YEAR}-${MONTH}-${DNUM}
        #echo $DATEOUTPUT

####################################
#Actual Data parsed to list the file
####################################

        zgrep -l "$OUTPUTDATE" /home/ceprod2/log/lri-console* > /home/sahook/sahook_scripts/CONSOLELOGFILE.txt

###################################
#Creating header file
##################################

        /bin/echo "UpdatedTime,SourceSystem,Location,Dataset,BusinessDate,SnapshotId" > /home/sahook/sahook_scripts/OutPut.txt
        /bin/echo "UpdatedTime,SourceSystem,Location,Dataset,BusinessDate,SnapshotId" > /home/sahook/sahook_scripts/OutPut1.txt

        for i in `cat CONSOLELOGFILE.txt`;
        do
        zgrep "Saving the snapshot Id" -A5 $i  | grep -v "\-\-" | awk '{getline b; getline c; getline d; getline e; getline f; printf("%s %s %s %s %s %s\n",$0,b,c,d,e,f)}' | awk -F':' '{print $1":"$2","$5","$6","$7","$9","$10}' | sed 's/  Location  //g;s/ Dataset//g;s/ BusinessDate //g;s/ snapshotId //g' | awk '{sub(/^ +/,""); gsub(/, /,",")}1' >> /home/sahook/sahook_scripts/OutPut.txt
        done
        grep ",$DATEOUTPUT," /home/sahook/sahook_scripts/OutPut.txt >> /home/sahook/sahook_scripts/OutPut1.txt
        awk '{if (NR==1) {print "SerialNo.,"$0} else {print NR-1","$0} }' /home/sahook/sahook_scripts/OutPut1.txt > /home/sahook/sahook_scripts/OutPut.txt
        cat /home/sahook/sahook_scripts/OutPut.txt
}
# Get Current day, then determine how many days to go back to
CurrentDD=`date '+%a'`
if [ "$CurrentDD" = "Mon" ]
then
        GetLastBusinessDay 3
elif [ "$CurrentDB" = "Sun" ]
then
        GetLastBusinessDay 2
else
        GetLastBusinessDay 1
fi

