#!/bin/bash
#Check image count of current scan directories
source ~/SoilCam/ProcessFiles/locations.cfg
loc=~/SoilCam/videos
COUNTDAY=2
total=0
today=$(date -d "today" +"%Y%m%d")
weeklyreport ()
{
	echo -e "date\t\tsoil\ttotal videos"
	while [ $COUNTDAY -ge 0 ];
	do
		prev=$(date -d "$COUNTDAY Days Ago" +"%Y%m%d")
		echo -en "$prev\t"
		for i in ${dirs[@]};
		do
			ls -1 $loc/$i/*"$prev"*.mp4 &>/dev/null
			if [ $? -eq 0 ];
			then
				count=$(ls -1 $loc/$i/*"$prev"*.mp4 | wc -l)
				size=$(du -ch $loc/$i/*"$prev"*.mp4 | grep total | awk '{ print $1 }')
			        echo -en "$(printf %03d $count)\t$size\t"
				total=$((total + count))
			else
				count=0
				echo -en "\t\t"
			fi
		done
		echo "$total"
		let COUNTDAY=COUNTDAY-1
	done
	echo -e "date\t\tsoil\ttotal videos"
}
weeklyreport
# | tee ~/SoilCam/Logs/CountVideos.txt
mail -s 'SOILCAM: Report' joshdont@gmail.com < ~/SoilCam/Logs/CountVideos.txt
