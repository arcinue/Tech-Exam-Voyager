#!bin/bash
#Author: Lorenzo S. Arcinue
#Date: June 16, 2016
#Purpose: Memory Check
######################################################

#Setting up Values
totalMemory=$( free | grep Mem: | awk '{print $2}' )
usedMemory=$( free | grep Mem: | awk '{print $3}' )
#Check Number a Parameters
while getopts ":c:w:e:" option;  
do
	case $option in
		c) critical=$OPTARG ;;
		w) warning=$OPTARG ;;
		e) email=$OPTARG ;;
	esac
done

#check if no parameters were supplied
if [ $# = 0 ]
then
	clear;
	echo The script is need 3 parameters.
	echo "-c : critical threshold (percentage)"
	echo "-w : warning threshold (percentage)"
	echo "-e : email address to send the report"
	echo Sample: memory_check.sh -c 90 -w 60 -e email@mine.com
elif [ $critical -lt $warning ]
then
	clear;
	echo ERROR: Critical threshold must be greater than Warning Threshold.
	echo 
	echo The script is need of 3 parameters.
	echo "-c : critical threshold (percentage)"
	echo "-w : warning threshold (percentage)"
	echo "Sample: memory_check.sh -c 90 -w 60 -e email@mine.com"
elif [[ $critical -ge 100 && $warning -ge 100 ]]
then 
	clear;
	echo Critical and Warning Threshold percentage must be less than 100.
	echo 
	echo The script is need of 3 parameters.
	echo "-c : critical threshold (percentage)"
	echo "-w : warning threshold (percentage)"
	echo "Sample: memory_check.sh -c 90 -w 60 -e email@mine.com"

else	#Exit of script
	critThreshold=$(($critical*$totalMemory/100))
	warnThreshold=$(($warning*$totalMemory/100))
	TIME=$( date +%Y%m%d\ %H:%M )
	topProcesses=$( ps axo pid,comm,rss,%mem --sort -rss | head -n 11 )
#check if critical threshold is greater than warning threshold
	if [[ $usedMemory -ge $critThreshold ]]
	then
		echo "$topProcesses" | mail -s "$CURRENT_TIME memory check - critical" $email
		exit 2
	elif [[ $usedMemory -ge $warnThreshold ]]
	then
		exit 1
	elif [[ $usedMemory -lt $warnThreshold ]]
	then
		exit 0
	fi
fi

#END



