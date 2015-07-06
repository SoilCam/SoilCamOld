#!/bin/bash
#This script builds a weekly compilation of previously compiled daily videos, it will look for the following arguments:
#	$1 is required to specify the working directory of videos. The script will look in /mnt/data/videos/
#	$2 is required the first time you process a set of videos and takes the form of YYYYmmdd, for example: 20150620
logs=~/SoilCam/Logs/BWCheck.txt
vidLoc="/mnt/data/videos/$1"
LastEndDate="/mnt/data/videos/$1/LastEndDate.txt"
NP=1

if [ -z $1 ]; then
	echo -e "No Starting Argument!"
	echo -e "\tYou must specify the name of the directory daily videos are stored in. We currently look under '/mnt/data/videos/'"
	exit 1;
fi
while [ $NP -ne 13 ];
do
	case "$NP" in
		1)	CP=$NP
			[ -d $vidLoc ] && NP=2 reason="$CP - Directory specified $vidLoc exists" || NP=11 reason="$CP - Directory specified $vidLoc does not exist"
			#echo "$reason"
		;;
		2)	CP=$NP
			[ -z $2 ] && NP=3 reason="$CP - No startdate argument, checking file" || NP=4 reason="$CP - Startdate Given" StartDate=$2
			#echo "$reason"
		;;
		3)	CP=$NP
			[ -f $LastEndDate ] && NP=4 reason="$CP - Found file with EndDate" StartDate="$(date --date="$(cat $LastEndDate)+1 days" +"%Y%m%d")" || NP="11" reason="$CP - No file found to base startdate off"
			#echo "$reason"
		;;
		4)	CP=$NP
			EndDate="$(date --date="$StartDate+6 days" +"%Y%m%d")"
			ToStart="$(( ($(date +%s) - $(date --date="$StartDate" +%s) )/(60*60*24) ))"
			ToEnd="$(( ($(date +%s) - $(date --date="$EndDate" +%s) )/(60*60*24) ))"
			NP=5
		;;
		5)	CP=$NP
			[ $EndDate -ge $(date -d "today" +"%Y%m%d") ] && NP=11 reason="$CP - EndDate in future, try again tomorrow!" || NP=6 reason="$CP - Date range within reality"
			#echo "$reason"
		;;
		6)	CP=$NP
			[ -d "$vidLoc/CompiledVideos" ] || mkdir "$vidLoc/CompiledVideos"
			# Store files name in dates array, this way we don't just make up the dates, we only add the dates if the files are found?
			cd $vidLoc
			dates=()
				while [ $ToStart -ge $ToEnd ]; do
				TheDate=$(date -d "$ToStart days ago" +"%Y%m%d")
				filename="$(ls $TheDate*.mp4.mpeg.ts)"
				ToStart=$((ToStart-1))
				dates+=($filename)
#				echo -e "\t$TheDate"
			done
			NP=7
		;;
		7)	CP=$NP
			[ "${#dates[@]}" -lt 6 ] && NP=11 reason="$CP - Number of video files found is less than 7, exiting" || NP=8 reason="$CP - Number of video files found is 7, good to go."
			#echo "$reason"
		;;
		8)	CP=$NP
			echo -e "$(date)\t$1\t$StartDate - $EndDate\tProcessing" >> $logs
			files=$(echo ${dates[@]} | tr ' ' '|') > $vidLoc/files.txt
			avconv -y -isync -i "concat:$vidLoc/$files|" -c copy CompiledVideos/$StartDate-$EndDate.mp4
			NP=9
		;;
		9)	CP=$NP
			[ -f CompiledVideos/$StartDate-$EndDate.mp4 ] && NP=10 reason="$CP - New weekly video file found" || NP=11 reason="$CP - New weekly video file  not found"
			#echo "$reason"
		;;
		10)	CP=$NP
			echo -e "$EndDate" > $LastEndDate
			[ -f $LastEndDate ] && NP=12 reason="$CP - Next weekly video will start the day after: $(cat $LastEndDate)" || NP=11 reason="$CP - LastEndDate not updated, but video file was made. Whaaat?"
			#echo "$reason"
		;;
		11)	echo -e "$(date)\t$1\t$StartDate - $EndDate\tStopped at: $reason" >> $logs
			NP=13
		;;
		12) 	echo -e "$(date)\t$1\t$StartDate - $EndDate\tFinished at: $reason" >> $logs
			NP=13
		;;
	esac
done
