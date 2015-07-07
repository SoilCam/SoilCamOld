#!/bin/bash
#This script should build the files needed for you to add another scanner.
#additional modification will likely be needed ; )
source ~/SoilCam/processFiles/locations.cfg

if [ $# -lt 2 ]
then
	echo -e "Usage: -A (Add) or -R (Remove), followed by an 8 character directory name\n \
	example: './AddScanner.sh -A soil' will add files and config settings using the name 'soil'"
	exit 1;
else
	if ! [[ "$2" =~ [^a-zA-Z0-9\_\-] ]];
	then
		[ $1 == "-A" ] && NP=2
		[ $1 == "-R" ] && NP=3
	else
		echo "The term '$2' you used must only contain letters, numbers, hyphens and underscores. No other funny business allowed"
		exit 1;
	fi
fi

while [ $NP -ne 10 ];
do
	case "$NP" in
		1)	CP=$NP
		;;

		2) 	CP=$NP
			read -p "You want to create the image and video directory $2, as well as config files to process images into video? (Yy/Nn)" -n 1 -r
			echo ""
			if [[ $REPLY =~ ^[Yy]$ ]]
			then
				read -p "If there is already a directory named '$2', it and all its contents will be overwritten. Are you okay with this? (Yy/Nn)" -n 1 -r
				echo ""
				if [[ $REPLY =~ ^[Yy]$ ]]
				then
					echo "Okay, processing..."
					NP=5
				else
					echo "Exiting"
					exit 1;
				fi
			else
				echo "Exiting"
				exit 1;
			fi
		;;
		3) 	CP=$NP
			read -p "Are you sure you wish to DELETE $2 associated files? (Yy/Nn) " -n 1 -r
			if [[ $REPLY =~ ^[Yy]$ ]]
				echo ""
			then
				read -p "We are about to delete the config file, scripts, images and any videos associated with $2, are you sure? (Yy/Nn)" -n 1 -r
				if [[ $REPLY =~ ^[Yy]$ ]]
				echo ""
				then
					NP=4
					echo "Proceeding to delete all of the files"
				fi
			else
				echo "Yay, nothing will be deleted, exiting!"
				exit 1;
			fi
		;;
		4) 	CP=$NP
			new_directory=$2
			new_prefix="${2:0:2}_"

			echo -e "Deleting directory:\t$baseImg/$new_directory/"
			echo -e "Deleting directory:\t$baseVid/$new_directory/"
			echo -e "Removing Image and Video file Prefix:\t$new_prefix"
			echo -e "Deleting config file:\t$baseScr/PI_$new_directory.cfg"
			read -p pause
			rm -rf $baseVid/$new_directory
			rm -rf $baseImg/$new_directory
			rm -rf $baseScr/PI_$new_directory.cfg
			NP=10
		;;
		5) 	CP=$NP #add files
			new_directory=$2
			new_prefix="${2:0:2}_"

			echo -e "Adding directory:\t$baseImg/$new_directory/"
			echo -e "Adding directory:\t$baseVid/$new_directory/"
			echo -e "Image and Video file Prefix will be:\t$new_prefix"
			echo -e "Adding new config file:\t$baseScr/PI_$new_directory.cfg"
			read -p pause
			mkdir $baseVid/$new_directory
			mkdir $baseImg/$new_directory

			rep_directory=$new_directory rep_prefix=$new_prefix envsubst < $baseScr/PI_template.cfg >> $baseScr/PI_$new_directory.cfg
			NP=10
		;;
		10) 	CP=$NP
			exit 1;
		;;
	esac
done
