#!/bin/bash
cd /var/www/tmp/
#start a 300 dpi scan, convert it to a jpg and flip it vertically
echo "$(date -d "today" +"%Y%m%dT%H%M%S") scan start" >> /var/www/log_sq_$(date -d "today" +"%Y%m%d").txt
file=ss_$(date -d "today" +"%Y%m%dT%H%M%S").jpg

sudo /usr/bin/scanimage -d plustek -l 0mm -t 0mm -x 215mm -y 297mm --mode Color --format tiff --resolution 300 | sudo /usr/bin/convert - /var/www/tmp1/squirrel/$file
mv /var/www/tmp1/squirrel/$file /var/www/tmp2/squirrel/$file

echo "$(date -d "today" +"%Y%m%dT%H%M%S") scan complete" >> /var/www/log_sq_$(date -d "today" +"%Y%m%d").txt
#rsync --remove-source-files -rv /var/www/tmp/squirrel/ pi@192.168.1.70:/mnt/data/images/squirrel >> /var/www/log_sq_$(date -d "today" +"%Y%m%d").txt
