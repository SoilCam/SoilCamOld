#!/bin/bash
#REQUIREMENTS for this script
#	$1	directory name used to locate video
#	$2	public, unlisted, or private

#Options for youtube-upload command arguments below
#	  -t TITLE, --title=TITLE				Video title
#	  -c CATEGORY, --category=CATEGORY			Video category
#	  -d DESCRIPTION, --description=DESCRIPTION		Video description
#	  --tags=TAGS           				Video tags (separated by commas: "tag1, tag2,...")
#	  --privacy=STRING      				Privacy status (public | unlisted | private)
#	  --location=latitude=VAL,longitude=VAL[,altitude=VAL]	Video location"
#	  --title-template=STRING				Template for multiple videos (default: {title}	[{n}/{total}])
#	sudo youtube-upload --title="SoilCam April 14th Test Upload" 20150412-155242-20150412-235801.mp4
logs=~/logs/YTcheck.txt
vidLoc=/mnt/data/videos/$1/CompiledVideos
#linfo="$date\t$1\t$2"
echo -e "$(date)\t$1\t$2" >> $logs
cd $vidLoc/
if [ -d $vidLoc/uploaded ]
then
        echo -e "$(date)\t$1\t$2\t$vidLoc/uploaded Directory found, no need to create" >> $logs
else
        echo -e "$(date)\t$1\t$2\tNo directory found at $vidLoc/uploaded, let us make one" >> $logs
        mkdir $vidLoc/uploaded
	if [ -d $vidloc/uploaded ];
	then
		echo "Created directory? : )" >> $logs
	else
		echo "Failed to create directory: $vidLoc/uploaded, this is not right. Lets quit guys." >> $logs
		exit 1;
	fi
fi

if [ -f *.mp4 ]
then
        echo -e "$(date)\t$1\t$2\tWe found a file. Let us upload it" >> $logs
        for file in *.mp4;
        do
	sudo youtube-upload --title="$file" --description="SoilCam! More info at http://soilcam.blogspot.com" --privacy=$2 $file >> $logs
                mv $file $vidLoc/uploaded/
        done
else
        echo -e "$(date)\t$1\t$2\tNo files to upload today, exiting!" >> $logs
        exit 0;
fi
