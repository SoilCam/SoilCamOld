#!/bin/bash
#Take a scan, process the image, timestamp, and generate a video from the images
#taken over the previous day
#This is intended to be run at a specific scheduled via CRON
#See usage details below

imgloc0=~/public_html/images			# directory to store images
imgloc1=~/public_html/images/new		# new images go here temp.
imgloc2=~/public_html/images/processing		# modified images temp. here
imgloc3=~/public_html/images/original		# originals stored here long term
imgloc4=~/public_html/images/tobedeleted	# modified images here after processing
vidloc=~/public_html/videos			# videos
setup(){
	dirs=("$imgloc0" "$imgloc1" "$imgloc2" "$imgloc3" "$imgloc4" "$vidloc")
	for i in "${dirs[@]}"
	do
		if [ ! -d "$i" ]; then
			read -p "'$i' is not a directory, shall I create it? (Yy or Nn)"
			if [[ $REPLY =~ ^[Yy]$ ]]; then
				mkdir $i
				if [[ $? -eq 0 ]];  then
					echo "Success, created $i directory"
					echo ""
				else
					echo "Try creating public_html directory in home by typing 'mkdir ~/public_html'"
#	We could do this for the user, but this is an opportunity for them to learn
					exit 1
					echo ""
				fi
			else
				echo "You have told me not to make '$i', but I need this! Exiting now."
				exit 1
			fi
		else
			continue
		fi
	done
}

usage(){
	echo -e "Usage: Primarily through cron/some automating process:
	-s	Checks directory structure needs, asks and builds if needed.
		Start a scan, convert to jpg and save image in new directory.
		-s is intended to be run every 15 minutes, starting on the hour

	-p	process the last image scanned: timestamp, resize, save in pro
		cessing folder as temp_ numbered file, move unmodified image
		from new to original directory.
		-p is already called when -s is used.

	-v	build video out of images in processing folder, move images to
		tobedeleted.
		-v is intended to be run as a cron job 5 minutes after midnight

	-t	build video out of images in processing folder, does not move
		images after processed. Videos processed prefixed t_.
		-v is intended to be run manually as a test

	-u	upload a yesterday's processed video (mp4) to youtube. Only
		works if you have youtube-upload and dependencies installed
		-u is intended to run via cron a good time after -v is done.
	"
}
goscango(){
	setup
	#start a scan at 300 DPI, save as JPG with date & time stamp
	echo "Starting Scan"
	file=sc_$(date -d "today" +"%Y%m%dT%H%M%S").jpg
	/usr/bin/scanimage --mode Color --format tiff --resolution 300 -x 210 -y 295 | /usr/bin/convert -flip -flop - $imgloc1/$file
	if [[ $? -eq 0 ]]; then
		echo "Scan completed, moving onto process the image"
		processimages
	else
		echo "Could not scan. Is the scanner plugged in? Have you installed ImageMagick?"
		exit 1
	fi
}

processimages(){
	TheDate=$(date -d today  +%Y%m%d)
	period="sc_$TheDate"
#	get number of temp files already in temp dir
	if [ "$(ls -A $imgloc2)" ]; then
		tfiles=$(ls -1 $imgloc2/temp_*.jpg | wc -l)
		count=$tfiles
		echo "Found $count previously processed files in temp directory"
	else
		echo "No files in temp directory, setting count to 0"
		count=0
	fi

#	move files from new directory to processing directory, exit if no images found.
	if mv $imgloc1/*.jpg $imgloc2/; then
		echo "Image found to process, let's resize and timestamp!"
	else
		echo "No image found to process, exiting..."
		exit 1
	fi
	cd $imgloc2
	for file in $period*.jpg; do
		counter=$(printf %04d $count);
		ndate="${file:3:4}\/${file:7:2}\/${file:9:2}"
		ntime="${file:12:2}:${file:14:2}:${file:16:2}"
                if convert $file -resize x1080 -crop 769x1080-1+0 - | convert -background '#0008'   \
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
                     "temp_$counter".jpg; then
			echo "Success!"
	                count=$(($count+1));
			mv $file $imgloc3/
		else
			echo "Something broke..."
		fi
        done
#	file counts
#	pfiles=$(ls -1 $imgloc3/$period*.jpg | wc -l)
#	ofiles=$(ls -1 $imgloc1/$period*.jpg | wc -l)
#	tfiles=$(ls -1 $imgloc2/temp_*.jpg | wc -l)
#	echo "Orig: $ofiles Proc: $pfiles Temp: $tfiles"

}

processvideo(){
#	This is designed to be run five minutes after midnight
#	Combine all images from processing into a video
	echo "Processing a video"
	TheDate=$(date -d yesterday  +%Y%m%d)
	if mv $imgloc2/*.jpg $imgloc4/; then
		echo "Found images to process into a video"
		if avconv -y -r 30 -i $imgloc4/temp_%04d.jpg -r 30 -vcodec libx264 -crf 20 -g 15 $vidloc/sc_$TheDate.mp4; then
			avconv -y -i $vidloc/sc_$TheDate.mp4 -f mpegts -c copy -bsf:v h264_mp4toannexb $vidloc/sc_$TheDate.mpeg.ts
			sleep 1
			rm $imgloc4/*.jpg
			ip=$(hostname -I | cut -f1 -d' ')
			echo ""
			echo "Video sc_$TheDate.mp4 generated, check for it in $vidloc, or via web at: http://$ip/~pi/videos/"
		else
			echo "Something bad happened trying to process the ideo. Aborting."
			exit 1
		fi
	else
		echo "No images found to process video"
		exit 1
	fi
}
processtempvideo(){
#	This is designed to process videos from today, whenever you please
#	It does NOT however move any files around. This is primarily used for testing purposes
	echo "Process temporary video. This file will be prefixed with a 't_'"
	TheDate=$(date -d today +%Y%m%d)
	if avconv -y -r 30 -i $imgloc2/temp_%04d.jpg -r 30 -vcodec libx264 -crf 20 -g 15 $vidloc/t_sc_$TheDate.mp4; then
		avconv -y -i $vidloc/t_sc_$TheDate.mp4 -f mpegts -c copy -bsf:v h264_mp4toannexb $vidloc/t_sc_$TheDate.mpeg.ts
		sleep 1
		ip=$(hostname -I | cut -f1 -d' ')
		echo ""
		echo "Video t_sc_$TheDate.mp4 generated, check for it in $vidloc, or via web at: http://$ip/~pi/videos/"
	else
		echo "Failed to process video"
		exit 1
	fi
}

uploadvideo(){
#	This is intended to be called after video has been processed
	TheDate=$(date -d yesterday +%Y%m%d)
	youtube-upload \
	--title="SoilCam $TheDate" \
	--description="Daily video uploaded from a SoilCam in Ann Arbor, MI, \
	 more details at http://soilcam.blogspot.com" \
	--category="Science & Technology" \
	--tags="soil, dirt, earth, worms, nematodes, decomposing" \
	--client-secrets="my_client_secret.json" \
	$vidloc/sc_$TheDate.mp4
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
		-U|-u)
			uploadvideo
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
