This is a simple script intended to make it easier to create timelapse videos 
with a scanner. Ideally run as a CRON job at various points.

It requires a number of programs that do the real work:
 - Apache2
 - AVConv
 - Bash
 - ImageMagick
 - SANE
 - YouTube-Upload (optional)

It requires hardware:
 - Scanner compatible with SANE ( http://www.sane-project.org/sane-mfgs.html )
 -- Tested with a Canon Lide 110
 -- Other scanners may require minor changes to scan function

 - Powered USB Hub
 -- Tested with a 4 Port Plugable Power USB Hub

 - 8GB SD Card minimum. 16 or 32 GB preferred.
 -- Default setup stores ~300 MB of data each day.

Intended to run on a Raspberry 2 running Raspbian. Should run fine on a Pi1or3
 - Tested running the March 2016 release of Raspbian
 - http://www.raspberrypi.org

More information about this project at: http://soilcam.blogspot.com

 - Josh Williams
 - joshdont@gmail.com
