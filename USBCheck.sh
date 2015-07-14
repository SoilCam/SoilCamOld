#!/bin/bash
#get the device number after unplugging/replugging in a device.
#Temporary file. Long term this should be part of a script that makes it easier for people to add
#multiple scanners of the same make/model/serial # to their Pi.
getScanner()
{
	echo "Please read!
	1.) All scanners must be unplugged before we continue.

	2.) Make note of what scanner you are using

	3.) Make note of what USB Port you are connecting said scanner into, and use a DIFFERENT USB Port for each scanner you use.

	4.) Only plug in ONE scanner at a time."

	echo ""

	read -p "Now if you have not already done so, unplug your scanner(s) and hit the enter key to continue"
	echo "Waiting one second..."
	sleep 1
	d1="$(find /sys/devices/ -name devnum)"

	read -p "plug in your device and hit the enter key to continue"
	echo "Waiting a couple seconds..."
	sleep 1
	d2="$(find /sys/devices/ -name devnum)"

	devpath=$(diff --unchanged-line-format= --old-line-format= --new-line-format='%L' <(echo "$d1") <(echo "$d2") | sed 's,/sys,,g' | sed 's,/devnum,,g')

	backend=$(scanimage -f %d | cut -d : -f 1)
}
