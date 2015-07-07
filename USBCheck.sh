#!/bin/bash
#get the device number after unplugging/replugging in a device.
#Temporary file. Long term this should be part of a script that makes it easier for people to add
#multiple scanners of the same make/model/serial # to their Pi.

read -p "unplug your device, hit a key when you are ready"
find /sys/devices/ -name devnum -exec cat {} \; > check1.txt
sleep 1
read -p "plug in your device, hit a key when you are ready"
find /sys/devices/ -name devnum -exec cat {} \; > check2.txt

result=$(diff --unchanged-line-format= --old-line-format= --new-line-format='%L' check1.txt check2.txt)

echo $result

rm check1.txt
rm check2.txt
