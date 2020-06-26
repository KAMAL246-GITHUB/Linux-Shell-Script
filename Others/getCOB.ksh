#!/bin/ksh
#set -x
GetLastBusinessDay()
{
        set -A MONTHS Dec Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec
        BACK=$1
        THEN=$((`date +%d` - $BACK))
        MONTH=`date +%m`
        YEAR=`date +%Y`
        WEEKDAY=${DAYS[`date +%u`]}
        if [ $THEN -le "0" ]
        then
                MONTH=$((MONTH-1))
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
        echo $THEN $WEEKDAY $MONTH $TMONTH $YEAR
}
# Get Current day, then determine how many days to go back to
CurrentDD=`date '+%a'`
if [ "$CurrentDD" = "Mon" ]
then
        GetLastBusinessDay 3
elif [ "$CurrentDD" = "Sun" ]
then
        GetLastBusinessDay 2
else
        GetLastBusinessDay 1
fi
