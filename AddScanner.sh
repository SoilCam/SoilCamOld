#!/bin/bash
#This script should build the files needed for you to add another scanner.
#additional modification will likely be needed ; )
source ~/SoilCam/processFiles/locations.cfg
source ~/SoilCam/USBCheck.sh
defexit="The term '$name' you used must be at least two characters in length and may only contain letters, numbers, hyphens and underscores. No other funny business allowed"

if [ $# -lt 2 ]
then
        echo -e "Usage:
        -a 	add a scanner, followed by a name (must be 2 or more characters in length and consist only of letters, numbers, underscores and/or hyphens)
        -d 	delete a scanner, followed by its name
        -m      If you are attaching multiple scanners of the exact same make and model
        -r      Specify a resolution for your scanner. Use only if you are familiar with both your scanners resolution limits AND SANE (scanimage)'s support
        example: ./AddScanner.sh -a -n soil -r 600
                This will add a config file and build the directory structure under the name "soil". We will scan at 600DPI

        This script is intended to add or remove the base directory structure, files, and config settings \n\
        for a scanner."
        exit 1;
else
        while [ $# -gt 0 ]; do
                case "$1" in
                        -A|-a)
                                l=$(expr length $2)
                                if [[ $l -lt 2 ]] || [[ "$2" =~ [^a-zA-Z0-9\_\-] ]];
                                then
                                        echo "$defexit"
                                        exit 1;
                                else
                                        name="$2"
                                        echo $name
                                fi
                                NP=2
                        ;;
                        -D|-d)
                                l=$(expr length $2)
                                if [[ $l -lt 2 ]] || [[ "$2" =~ [^a-zA-Z0-9\_\-] ]];
                                then
                                        echo "$defexit"
                                        exit 1;
                                else
                                        name="$2"
                                        echo $name
                                fi
                                NP=3
                        ;;
                        -M|-m)
                                MultipleScanners=Yes
                        ;;
                        -R|-r)  echo "Resolution = $2"
                                resolution="$2"
                        ;;
                esac
                shift
        done
fi

while [ $NP -ne 10 ];
do
	case "$NP" in
		1)	CP=$NP
		;;

		2) 	CP=$NP
			read -p "You want to create the image and video directory $name, as well as config files to process images into video? (Yy/Nn)" -n 1 -r
			echo ""
			if [[ $REPLY =~ ^[Yy]$ ]]
			then
				read -p "If there is already a directory named '$name', it and all its contents will be overwritten. Are you okay with this? (Yy/Nn)" -n 1 -r
				echo ""
				if [[ $REPLY =~ ^[Yy]$ ]]
				then
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
			read -p "Are you sure you wish to DELETE $name associated files? (Yy/Nn) " -n 1 -r
			if [[ $REPLY =~ ^[Yy]$ ]]
			then
				echo ""
				read -p "We are about to delete the config file, scripts, images and any videos associated with $name, are you sure? (Yy/Nn)" -n 1 -r
				if [[ $REPLY =~ ^[Yy]$ ]]
				then
					echo ""
					NP=4
					echo "Proceeding to delete all of the files"
				fi
			else
				echo "Yay, nothing will be deleted, exiting!"
				exit 1;
			fi
		;;
		4) 	CP=$NP
			new_directory=$name
			new_prefix="${name:0:2}_"

			echo -e "Deleting directory:\t$baseImg/$new_directory/"
			echo -e "Deleting directory:\t$baseVid/$new_directory/"
			echo -e "Removing Image and Video file Prefix:\t$new_prefix"
			echo -e "Deleting config file:\t$baseScr/PI_$new_directory.cfg"
			rm -rf $baseVid/$new_directory
			rm -rf $baseImg/$new_directory
			rm -rf $baseScr/PI_$new_directory.cfg
			NP=10
		;;
		5) 	CP=$NP #add files
			new_directory=$name
			new_prefix="${name:0:2}_"
			if [[ -z $resolution ]]
			then
				new_resolution=300
			else
				new_resolution=$resolution
			fi
			echo -e "Adding directory:\t$baseImg/$new_directory/"
			echo -e "Adding directory:\t$baseVid/$new_directory/"
			echo -e "Image and Video file Prefix will be:\t$new_prefix"
			echo -e "Adding new config file:\t$baseScr/PI_$new_directory.cfg"
			echo -e "Specifying default scan resolution of $new_resolution"
			echo -e "MultipleScanners: $MultipleScanners"
			mkdir $baseVid/$new_directory
			mkdir $baseImg/$new_directory

			if [[ "$MultipleScanners" == "Yes" ]]
			then
				echo "I think there are multiple scanners"
				getScanner
				rep_directory=$new_directory rep_prefix=$new_prefix rep_resolution=$new_resolution rep_backend=$backend rep_devpath=$devpath rep_multipleScanners=$MultipleScanners envsubst < $baseScr/PI_template.cfg >> $baseScr/PI_$new_directory.cfg
			else
				echo "I do NOT think there are multiple scanners"
				getScannerSimple
				rep_directory=$new_directory rep_prefix=$new_prefix rep_resolution=$new_resolution rep_backend=$backend envsubst < $baseScr/PI_template.cfg >> $baseScr/PI_$new_directory.cfg
			fi

			NP=10
		;;
		10) 	CP=$NP
			echo "Mission Accomplished... hopefully"
			exit 1;
		;;
	esac
done
