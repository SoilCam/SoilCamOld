#!/bin/bash
loc=/mnt/data/images/soil
resize="-resize x1920" # we create an image slightly wider than 1920px, this allows us to later crop out the silicone border
rotate="-rotate 270" # rotate the image 270 degrees. For whatever reason we're rotating the image in the scan process. This is silly
width=$((1920 / 5))
cd $loc
file=$(find . -maxdepth 1 -type f -printf '%T@ %p\n' | sort -n | tail -1 | cut -c 25-46)
ntime="${file:12:2}:${file:14:2}:${file:16:2}"
ndate="${file:3:4}\/${file:7:2}\/${file:9:2}"
convert $loc/$file $resize $rotate - | convert -background black\
     -gravity center        \
     -fill white            \
     -size ${width}x50     \
      caption:"${ndate} ${ntime}"      \
     -             \
     +swap                  \
     -gravity south         \
     -composite             \
     /mnt/data/images/current.jpg

scp /mnt/data/images/current.jpg soilcam@104.237.129.165:/home/soilcam/images/soil/current.jpg

