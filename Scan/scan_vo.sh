#!/bin/bash
cd /var/www/tmp
#start a 300 dpi scan, convert it to a jpg and flip it vertically
voel=$(/sbin/udevadm info --query=all --path=/devices/platform/bcm2708_usb/usb1/1-1/1-1.2/1-1.2.3 | grep DEVNUM)
voel="${voel:10:3}"
file=sv_$(date -d "today" +"%Y%m%dT%H%M%S").jpg

echo "$(date -d "today" +"%Y%m%dT%H%M%S") scan started" >> /var/www/log_vo_$(date -d "today" +"%Y%m%d").txt
sudo /usr/bin/scanimage -d genesys:libusb:001:$voel -l 0mm -t 0mm -x 215mm -y 297mm --mode Color --format tiff --resolution 300 | sudo /usr/bin/convert - /var/www/tmp1/voel/$file
mv /var/www/tmp1/voel/$file /var/www/tmp2/voel/$file

echo "$(date -d "today" +"%Y%m%dT%H%M%S") scan complete" >> /var/www/log_vo_$(date -d "today" +"%Y%m%d").txt
#rsync --remove-source-files -rv /var/www/tmp/voel/ pi@192.168.1.70:/mnt/data/images/voel >> /var/www/log_vo_$(date -d "today" +"%Y%m%d").txt
