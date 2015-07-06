#!/bin/bash
#Check image count of current scan directories
loc=/mnt/data/images
dirs=(soil shrew ratpaw squirrel voel)
COUNTDAY=2
total=0
today=$(date -d "today" +"%Y%m%d")
weeklyreport ()
{
echo -e "date\t\tsoil\t\tshrew\t\tratpaw\t\tsquirrel\tvoel\t\ttotal images"
while [ $COUNTDAY -ge 0 ];
do
	prev=$(date -d "$COUNTDAY Days Ago" +"%Y%m%d")
	echo -en "$prev\t"
	for i in ${dirs[@]};
	do
		ls -1 $loc/$i/*"$prev"*.jpg &>/dev/null
		if [ $? -eq 0 ];
		then
			count=$(ls -1 $loc/$i/*"$prev"*.jpg | wc -l)
			size=$(du -ch $loc/$i/*"$prev"*.jpg | grep total | awk '{ print $1 }')
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
echo -e "date\t\tsoil\t\tshrew\t\tratpaw\t\tsquirrel\tvoel\t\ttotal images"
}
weeklyreport | tee ~/SoilCam/Logs/CountImages.txt
mail -s 'SOILCAM: Report' joshdont@gmail.com < ~/SoilCam/Logs/CountImages.txt
