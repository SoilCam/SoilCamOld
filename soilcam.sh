#!/bin/bash
#Take a scan, process the image, timestamp, and generate a video from the images
#taken over the previous day
#This is intended to be run at a specific scheduled via CRON
#See usage details below

imgloc1=~/public_html/images/new		# new images go here temp.
imgloc2=~/public_html/images/processing		# modified images temp. here
imgloc3=~/public_html/images/processed		# originals stored here long term
imgloc4=~/public_html/images/tobedeleted	# modified images here after processing
vidloc=~/public_html/videos			# videos

usage(){
	echo -e "Usage: Unintended to be run manually!
	-s	start a scan
		-s is intended to be run every 15 minutes, starting on the hour
	-p	process the last image scanned (timestamp, resize, save in processing folder
		-p is already called when -s is used.
	-v	build video out of images in processing folder, move images to processed
		-v is intended to be run as a cron job 5 minutes after midnight
	-t	build video out of images in processing folder, do not move after processed
		-v is intended to be run manually as a test, no images are deleted or moved
		All videos processed in this mode are prefixed with a t_
	"
}
goscango(){
	#start a scan at 300 DPI, save as JPG with date & time stamp
	echo "Make Scan Go"
	file=sc_$(date -d "today" +"%Y%m%dT%H%M%S").jpg
	/usr/bin/scanimage --mode Color --format tiff --resolution 300 -y 299 | /usr/bin/convert - $imgloc1/$file
	processimages
}

processimages(){
	echo "Process image"
	TheDate=$(date -d today  +%Y%m%d)
	period="sc_$TheDate"
#	get number of temp files already in temp dir
	tfiles=$(ls -1 $imgloc2/temp_*.jpg | wc -l)
#	move files from new directory to processing directory
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
#	This is designed to be run five minutes after midnight
#	Combine all images from processing into a video
	echo "Process video"
	TheDate=$(date -d yesterday  +%Y%m%d)
	if mv $imgloc2/*.jpg $imgloc4/; then
		if avconv -y -r 30 -i $imgloc4/temp_%04d.jpg -r 30 -vcodec libx264 -crf 20 -g 15 $vidloc/sc_$TheDate.mp4; then
			avconv -y -i $vidloc/sc_$TheDate.mp4 -f mpegts -c copy -bsf:v h264_mp4toannexb $vidloc/sc_$TheDate.mpeg.ts
			sleep 1
			rm $imgloc4/*.jpg
		else
			echo "failed to process video"
		fi
	else
		echo "failed to find images?"
	fi
}
processtempvideo(){
#	This is designed to process videos from today, whenever you please
#	It does NOT however move any files around. This is primarily used for testing purposes
	echo "Process video temporarily"
	TheDate=$(date -d today +%Y%m%d)
	if avconv -y -r 30 -i $imgloc2/temp_%04d.jpg -r 30 -vcodec libx264 -crf 20 -g 15 $vidloc/t_sc_$TheDate.mp4; then
	avconv -y -i $vidloc/t_sc_$TheDate.mp4 -f mpegts -c copy -bsf:v h264_mp4toannexb $vidloc/t_sc_$TheDate.mpeg.ts
	sleep 1
	else
		echo "failed to process video"
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
		-T|-t)
			processtempvideo
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
