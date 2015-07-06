#!/bin/bash
source ~/SoilCam/processFiles/locations.cfg
loc=~/SoilCam
COUNTDAY=2
0DoImagesExist()
{
	CP=0
	files=$(ls -1 $loc/images/${dirs[$index]}/${prefix[$index]}_$theDate*.jpg | wc -l)
	if [ $files -ne 0 ]; then
		NP=1
	else
		NP=6
	fi

}
1DoesTARexist()
{
	CP=1
	if [ -f $loc/tarfiles/${prefix[$index]}_$theDate2.tar ]; then
		echo -e "\tYes"
		NP=3
	else
		echo -e "\tNo"
		NP=2
	fi
}

2CreateTar()
{
	CP=2
	tar -cf $loc/tarfiles/${prefix[$index]}_$theDate2.tar $loc/images/${dirs[$index]}/${prefix[$index]}_$theDate*.jpg
	NP=3
}

3CompareTar()
{
	CP=3
	tarfc=$(tar -tvf $loc/tarfiles/${prefix[$index]}_$theDate2.tar | wc -l)
	if [ $tarfc -eq $files ]; then
		echo -e "\tMatch"
		NP=5
	else
		echo -e "\tNo Match"
		NP=4
	fi
}

4DeleteTar()
{
	CP=4
	rm $loc/tarfiles/${prefix[$index]}_$theDate2.tar
	NP=2

}

5NextSet()
{
	CP=5
	NP=7
}

6NoImages()
{
	CP=6
	NP=7
}

while [ $COUNTDAY -ne 0 ];
do
	theDate=$(date -d "$COUNTDAY days ago" +"%Y%m%d")
	theDate2=$(date -d "$COUNTDAY days ago" +"%Y_%m_%d")
	for index in ${!dirs[@]};
	do
		0DoImagesExist
		while [ $NP -ne 7 ];
		do
			case "$NP" in
			1)	echo -en "$(date +%Y%m%d-%H%M%S) - $theDate\t${prefix[index]}\tDoes TAR Exist?"
				1DoesTARexist
				;;
			2)	echo -e "$(date +%Y%m%d-%H%M%S) - $theDate\t${prefix[index]}\tCreate a TAR File"
				2CreateTar
				;;
			3)	echo -en "$(date +%Y%m%d-%H%M%S) - $theDate\t${prefix[index]}\tCompare Number of TAR files with number of Images"
				3CompareTar
				;;
			4)	echo -e "$(date +%Y%m%d-%H%M%S) - $theDate\t${prefix[index]}\tDelete TAR file. Presumably because it doesn not match with number of images"
				4DeleteTar
				;;
			5)	echo -e "$(date +%Y%m%d-%H%M%S) - $theDate\t${prefix[index]}\tAll is good, let us move on"
				5NextSet
				;;
			6)	echo -e "$(date +%Y%m%d-%H%M%S) - $theDate\t${prefix[index]}\tMissing images. Report!"
				6NoImages
				;;
			esac
		done
	done
	let COUNTDAY=COUNTDAY-1
done
