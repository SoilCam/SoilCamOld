#!/bin/bash
cd /var/www/tmp1
#start a 300 dpi scan, convert it to a jpg and flip it vertically
#set the port the scanner is attached to
scanner="/sys/devices/platform/bcm2708_usb/usb1/1-1/1-1.2/1-1.2.2"

#check to see if something is connected to that port.
#If nothing, email an alert. If something, try scanning.
if [ ! -d $scanner ];
then
        mail -s 'SOILCAM: Scanner Down' joshdont@gmail.com << EOF
Your $scanner  is not responding
EOF

else
	soil=$(/sbin/udevadm info --query=all --path=/devices/platform/bcm2708_usb/usb1/1-1/1-1.2/1-1.2.2 | grep DEVNUM)
	soil="${soil:10:3}"
	echo "$(date -d "today" +"%Y%m%dT%H%M%S") scan start" >> /var/www/log_so_$(date -d "today" +"%Y%m%d").txt
	file=so_$(date -d "today" +"%Y%m%dT%H%M%S").jpg
	sudo /usr/bin/scanimage -d genesys:libusb:001:$soil -l 0mm -t 0mm -x 213mm -y 292.5mm --mode Color --format tiff --resolution 600 | sudo /usr/bin/convert - /var/www/tmp1/soil/$file
	echo "$(date -d "today" +"%Y%m%dT%H%M%S") scan complete" >> /var/www/log_so_$(date -d "today" +"%Y%m%d").txt
	mv /var/www/tmp1/soil/$file /var/www/tmp2/soil/$file
fi
#scp /var/www/tmp/soil/$file soilcam@104.237.129.165:/home/soilcam/images/soil/current.jpg
#rsync --remove-source-files -rv /var/www/tmp/soil/ pi@192.168.1.70:/mnt/data/images/soil >> /var/www/log_so_$(date -d "today" +"%Y%m%d").txt
#216.7mm -y 297.6mm
#orig: 215x297
#test: 216.7x297.5mm = Not any better.
#test: 213x292.5mm
#ratio: 0.728403361
