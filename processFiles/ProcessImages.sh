#!/bin/bash
#Process the previous days images into a video
#I want three arguments. A StartDate, EndDate, and Configuration file in the form of:
#	ProcessImages.sh 20150620 20150620 PI_generic.cfg
	if [ -z "$1" ]
	then
	        echo "No StartDate (YYYYMMDD)"
	        exit 1
	else
	        StartDate=$(date -d $1 +%Y%m%d)
	        echo $StartDate
	fi

	if [ -z "$2" ]
	then
	        echo "No EndDate (YYYYMMDD)"
	        exit 1
	else
	        EndDate=$(date -d $2 +%Y%m%d)
	        echo $EndDate
	fi

	if [ -z "$3" ]
	then
	        echo "No Config File Specified, gotta exit"
	        exit 1
	fi

source ~/SoilCam/processFiles/PI_$3.cfg

ToEnd="$(( ($(date +%s) - $(date --date="$EndDate" +%s) )/(60*60*24) ))"
ToStart="$(( ($(date +%s) - $(date --date="$StartDate" +%s) )/(60*60*24) ))"


while [ $ToStart -ge $ToEnd ]; do
	x=1;
	TheDate=$(date -d "$ToStart days ago" +"%Y%m%d")
	period="$prefix$TheDate"
	files=$(ls -1 $imgloc/$period*.jpg | wc -l)
	cd $imgloc
	echo -e "$(date) \t ##### \t ##### \t ##### \t ##### \t ##### \t ##### \t #####" >> $logs
	echo -e "$(date)\t$prefix\tbegin\tresize timestamp save $period" >> $logs

	mkdir $period
	for file in $period*.jpg; do
		counter=$(printf %04d $x);
		echo "Currently processing image: $file, this may take some time."
		#Set aside date and time of each image for image caption
		ndate="${file:3:4}\/${file:7:2}\/${file:9:2}"
		ntime="${file:12:2}:${file:14:2}:${file:16:2}"


		#Save first and last image names in log file. Set bdate and edate for later use in video file name.
		if [ "$x" -eq 1 ]
		then
			echo -e "$(date)\t$prefix\tstatus\t First Image File:\t$file" >> $logs
			bdate="${file:3:8}-${file:12:6}"
		fi

		if [ "$x" -eq "$files" ]
		then
			echo -e "$(date)\t$prefix\tstatus\t Last Image File:\t$file" >> $logs
			edate="${file:3:8}-${file:12:6}"
		fi

		#Adjust the image file as specified in cfg file. Apply time stamp, save in temp directory
	        convert $file $one $two $three $four - | convert -background '#0008'   \
			-gravity center	\
			-fill white	\
			-size 400x30	\
			-pointsize 24	\
			-kerning 2.5	\
			-font Courier	\
			caption:"${ndate} ${ntime}"	\
			-	\
			+swap	\
			-gravity south	\
			-composite	\
	             $period/"temp_$counter".jpg
		x=$(($x+1));
	done
	echo -e "$(date)\t$prefix\tend\tresize timestamp save copy $period" >> $logs

	echo -e "$(date)\t$prefix\tbegin\tavconv encode $bdate - $edate" >> $logs
	#Use temp saved images as input for video file.
	avconv -y -r 30 -i $period/temp_%04d.jpg -r 30  -vcodec libx264 -crf 20 -g 15 $vidloc/${bdate}-${edate}.mp4
	#Save a raw mpeg in a format that can easily be stitched to another mpeg
	avconv -y -i $vidloc/${bdate}-${edate}.mp4 -f mpegts -c copy -bsf:v h264_mp4toannexb $vidloc/${bdate}-${edate}.mp4.mpeg.ts
	echo -e "$(date)\t$prefix\tend\tavconv encode $bdate - $edate" >> $logs

	#Do some cleanup
	echo -e "$(date)\t$prefix\tbegin\tcleanup $period" >> $logs
	rm $period/temp_*.jpg
	rmdir $period/
	echo -e "$(date)\t$prefix\tend\tcleanup $period" >> $logs
	let ToStart=ToStart-1
done
