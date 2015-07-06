#!/bin/bash
# Check and upload tar files
source ~/SoilCam/ProcessFiles/locations.cfg
logs=~/SoilCam/Logs/DailyUploadProcess.txt
loc=~/SoilCam
COUNTDAY=3
NP=0
0DoesLocalTARexist()
{
	if [ -f $loc/tarfiles/${prefix[$index]}_$theDate2.tar ]; then
		echo -e "$(date +%Y%m%d-%H%M%S) - $theDate\t${prefix[index]}\t $NP\tLocal Exists"
		NP=1
	else
		echo -e "$(date +%Y%m%d-%H%M%S) - $theDate\t${prefix[index]}\t $NP\tLocal NOT Exists"
		NP=4
	fi
}

1TestSync()
{
	echo -en "\tSyncing"
	/usr/local/bin/s3cmd sync $loc/tarfiles/${prefix[$index]}_$theDate2.tar s3://soilcam-backups/${dirs[$index]}/${prefix[$index]}_$theDate2.tar
	echo -e "\tSync Complete"
	NP=2
}

2DoesRemoteTARexist()
{
	local=$(stat --printf="%s" $loc/tarfiles/${prefix[$index]}_$theDate2.tar)
	remote=$(/usr/local/bin/s3cmd info s3://soilcam-backups/${dirs[$index]}/${prefix[$index]}_$theDate2.tar | grep 'File size: ')
	remote=${remote:13:16}
	if [ $local -eq $remote ]; then
		echo -e "\tLocal & Remote Match"
		NP=3
	else
		echo -e "\tLocal & Remote No Match, going to sync again"
		NP=1
	fi
}

3IsFileOld()
{
	if [ $COUNTDAY -gt 2 ]; then
		echo -e "\tDeleting because file is old and already on S3"
		rm $loc/tarfiles/${prefix[$index]}_$theDate2.tar
		NP=5
	else
		echo -e "\tFile is not old enough to delete"
		NP=5
	fi
}


4NoFilesToTar()
{
	echo -e "\tNo Files to TAR"
	NP=5
}

5AllDone()
{
	echo -e "\tHopefully all is good!"
	NP=6
}


while [ $COUNTDAY -gt 0 ];
do
	theDate=$(date -d "$COUNTDAY days ago" +"%Y%m%d")
	theDate2=$(date -d "$COUNTDAY days ago" +"%Y_%m_%d")
	for index in ${!dirs[@]};
        do
		NP=0
		0DoesLocalTARexist
		while [ $NP -ne 6 ];
		do
			case "$NP" in
				1) echo -en "$(date +%Y%m%d-%H%M%S) - $theDate\t${prefix[index]}\t $NP"
				1TestSync
				;;
				2) echo -en "$(date +%Y%m%d-%H%M%S) - $theDate\t${prefix[index]}\t $NP"
				2DoesRemoteTARexist
				;;
				3) echo -en "$(date +%Y%m%d-%H%M%S) - $theDate\t${prefix[index]}\t $NP"
				3IsFileOld
				;;
				4) echo -en "$(date +%Y%m%d-%H%M%S) - $theDate\t${prefix[index]}\t $NP"
				4NoFilesToTar
				;;
				5) echo -en "$(date +%Y%m%d-%H%M%S) - $theDate\t${prefix[index]}\t $NP"
				5AllDone
				;;
			esac
		done
        done
        let COUNTDAY=COUNTDAY-1
done
