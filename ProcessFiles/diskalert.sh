#!/bin/bash

parts=(/ /dev/sda2)
THRESHOLD=90

for i in ${parts[@]};
do
	CURRENT=$(/bin/df $i | grep / | awk '{ print $5}' | sed 's/%//g')
	if [ "$CURRENT" -gt "$THRESHOLD" ] ; then
    	mail -s 'Disk Space Alert' joshdont@gmail.com << EOF
Your $i partition remaining free space is critically low. Used: $CURRENT%"
EOF
	fi
done
