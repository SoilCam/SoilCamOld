#!/bin/bash
#cd /var/www/tmp1/ratpaw
#start a 1200 dpi scan, convert it to a jpg and flip it vertically
voel=$(/sbin/udevadm info --query=all --path=/devices/platform/bcm2708_usb/usb1/1-1/1-1.2/1-1.2.3 | grep DEVNUM)
voel="${voel:10:3}"
file=rp_$(date -d "today" +"%Y%m%dT%H%M%S").jpg

echo "$(date -d "today" +"%Y%m%dT%H%M%S") scan started" >> /var/www/log_rp_$(date -d "today" +"%Y%m%d").txt
sudo /usr/bin/scanimage -d genesys:libusb:001:$voel -l 128mm -t 38mm -x 40.7mm -y 22.86mm --mode Color --format tiff --resolution 1200 | sudo /usr/bin/convert - /var/www/tmp1/ratpaw/$file
mv /var/www/tmp1/ratpaw/$file /var/www/tmp2/ratpaw/$file

echo "$(date -d "today" +"%Y%m%dT%H%M%S") scan complete" >> /var/www/log_rp_$(date -d "today" +"%Y%m%d").txt
#rsync --remove-source-files -rv /var/www/tmp/ratpaw/ pi@192.168.1.70:/mnt/data/images/ratpaw >> /var/www/log_rp_$(date -d "today" +"%Y%m%d").txt
