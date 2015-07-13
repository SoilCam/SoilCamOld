#!/bin/bash
#start a 300 dpi scan, convert it to a jpg and flip it vertically
source ~/SoilCam/processFiles/locations.cfg
source ~/SoilCam/processFiles/PI_$1.cfg

file=${prefix}$(date -d "today" +"%Y%m%dT%H%M%S").jpg

if [[ "$MultipleScanners" =  "Yes" ]]
then
	echo "Scanning with $backend:libusb:001:$devpath"
	sudo /usr/bin/scanimage -d $backend:libusb:001:$devpath --mode Color --format tiff --resolution $res | sudo /usr/bin/convert - $imgloc/$file
else
	echo "Scanning generic"
	sudo /usr/bin/scanimage --mode Color --format tiff --resolution $res | sudo /usr/bin/convert - $imgloc/$file
fi


# -l 0mm -t 0mm -x 213mm -y 292.5mm
