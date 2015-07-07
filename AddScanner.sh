#!/bin/bash
#This script should build the files needed for you to add another scanner.
#additional modification will likely be needed ; )
source ~/SoilCam/processFiles/locations.cfg
NP=1

if [ $# -lt 2 ]
then
	echo -e "Usage: -A (Add) or -R (Remove), followed by an 8 character directory name\n \
	example: './AddScanner.sh -A soil' will add files and config settings using the name 'soil'"
	exit 1;
fi
if [ -z $1 ]
then
	echo "Specify -A or -R to add or remove everything related to a scan."
	exit 1;
fi

if [ -z $2 ]
then
	echo "Specify a name, please keep it short and simple (8 characters. Only letters, numbers, hyphens and underscores please"
	exit 1;
fi

while [ $NP -ne 0 ];
do
	case $NP in
	1) CP=$NP
		[ $1 == "-A" ] && NP=2 echo "We are going to add files and directories for under the name '$2'"
		[ $1 == "-R" ] && NP=3 echo "We are going to remove files and directories for under the name '$2'"
	;;
	2) CP=$NP
		echo "Now we add files!
		#new_directory=$1
		#new_prefix="${1:0:2}_"

		#echo "Directory will be: $new_directory"
		#echo "Prefix will be: $new_prefix"

		#mkdir $baseVid/$new_directory
		#mkdir $baseImg/$new_directory

		#rep_directory=$new_directory rep_prefix=$new_prefix envsubst < ~/SoilCam/processFiles/PI_template.cfg >> ~/SoilCam/processFiles/PI_$new_directory.cfg
		NP=0
	;;
	3) CP=$NP
		echo "Now we delete files! Are you sure we want to delete files!?
		read -p pause
		NP=0
	;;
	0) CP=$NP
	;;
	esac
done

### ADD FILES ###
#read -p pause
#

### DELETE FILES ###
