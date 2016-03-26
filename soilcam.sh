#!/bin/bash
#Take a scan, process the image, timestamp, and generate a video from the images
#taken over the previous day
#This is intended to be run at a specific scheduled via CRON
#See usage details below

imgloc1=~/public_html/images/original
imgloc2=~/public_html/images/processing
imgloc3=~/public_html/images/processed
imgloc4=~/public_html/images/tobedeleted
vidloc=~/public_html/videos

usage(){
	echo -e "Usage: Unintended to be run manually!
	-s	start a scan
		-s is intended to be run every 15 minutes, starting on the hour
	-p	process the last image scanned (timestamp, resize, save in processing folder
		-p is already called when -s is used.
	-v	build video out of images in processing folder, move images to processed
		-v is intended to be run as a cron job 5 minutes after midnight"

}
goscango(){
	#start a scan at 300 DPI, save as JPG with date & time stamp
	echo "Make Scan Go"
	file=sc_$(date -d "today" +"%Y%m%dT%H%M%S").jpg
	/usr/bin/scanimage --mode Color --format tiff --resolution 300 -y 299 | /usr/bin/convert - ~/public_html/images/original/$file
	processimages
}

processimages(){
	echo "Process image"
	TheDate=$(date -d today  +%Y%m%d)
	period="sc_$TheDate"
#	get number of temp files already in temp dir
	tfiles=$(ls -1 $imgloc2/temp_*.jpg | wc -l)
#	move files from original directory to processing directory
	mv $imgloc1/*.jpg $imgloc2/
	cd $imgloc2
	count=$tfiles;
	for file in $period*.jpg; do
		counter=$(printf %04d $tfiles);
		ndate="${file:3:4}\/${file:7:2}\/${file:9:2}"
		ntime="${file:12:2}:${file:14:2}:${file:16:2}"
                convert $file -resize x1080 -crop 769x1080-1+0 - | convert -background '#0008'   \
                        -gravity center \
                        -fill white     \
                        -size 400x30    \
                        -pointsize 24   \
                        -kerning 2.5    \
                        -font Courier   \
                        caption:"${ndate} ${ntime}"     \
                        -       \
                        +swap   \
                        -gravity south  \
                        -composite      \
                     "temp_$counter".jpg
                count=$(($tfiles+1));
		mv $file $imgloc3/
        done
#	file counts
	pfiles=$(ls -1 $imgloc3/$period*.jpg | wc -l)
	ofiles=$(ls -1 $imgloc1/$period*.jpg | wc -l)
	tfiles=$(ls -1 $imgloc2/temp_*.jpg | wc -l)
	echo "Orig: $ofiles Proc: $pfiles Temp: $tfiles"

}

processvideo(){
	echo "Process video"
#	If we run this at midnight, we need to set this for the prior day!
	TheDate=$(date -d yesterday  +%Y%m%d)
#	move files from temp dimage directory to new directory
#	otherwise, if it takes > 15 minutes to process video, we end up processing images we didn't want to?
	if mv $imgloc2/*.jpg $imgloc4/; then
		echo "success"
		sleep 1
		if avconv -y -r 30 -i $imgloc4/temp_%04d.jpg -r 30 -vcodec libx264 -crf 20 -g 15 $vidloc/sc_$TheDate.mp4; then
			avconv -y -i $vidloc/sc_$TheDate.mp4 -f mpegts -c copy -bsf:v h264_mp4toannexb $vidloc/sc_$TheDate.mpeg.ts
			echo "more success, deleting temp images"
			sleep 1
			rm $imgloc4/*.jpg
		else
			echo "failed to process video"
		fi
	else
		echo "failed to find images?"
	fi
}

# check for arguments, exit with explanation if none, or run if one given
if [ $# -ne 1 ]
then
	usage
	exit 1;
elif [ $# -eq 1 ]
then
	while [ $# -gt 0 ]; do
		case "$1" in
		-S|-s)
			goscango
			exit 1;
		;;
		-P|-p)
			processimages
			exit 1;
		;;
		-V|-v)
			processvideo
			exit 1;
		;;
		-H|-h|--help)
			usage
			exit 1;
		;;
		esac
		shift
	done
else
	usage
	exit 1;
fi