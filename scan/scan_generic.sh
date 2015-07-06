#!/bin/bash
#start a 300 dpi scan, convert it to a jpg and flip it vertically
source ~/SoilCam/processFiles/locations.cfg

file=ge_$(date -d "today" +"%Y%m%dT%H%M%S").jpg
sudo /usr/bin/scanimage --mode Color --format tiff --resolution 300 | sudo /usr/bin/convert - $baseImg/generic/$file

# -l 0mm -t 0mm -x 213mm -y 292.5mm
