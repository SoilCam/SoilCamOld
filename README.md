This is a simple script intended to make it easier to create timelapse videos with a scanner.

It requires a number of programs that do the real work:
 - Apache
 - AVConv
 - Bash (date, envsubst, read, this should all be included with if you're running Raspbian)
 - ImageMagick
 - SANE
 - YouTube-Upload (optional)

It requires hardware:
 - USB Powered Scanner that is fully compatible with SANE ( http://www.sane-project.org/sane-mfgs.html )
 - - Tested with a Canon Lide 110
 - Powered USB Hub
 - - Tested with a 4 Port Plugable Power USB Hub

It is intended to be run on a Raspberry Pi 2 running Raspbian. It will likely run on other hardware (Pi 1 is fine, just a lot slower) 
 - Tested running the March 2016 release of Raspbian
 - http://www.raspberrypi.org

More information about this project at: http://soilcam.blogspot.com

 - Josh Williams
 - joshdont@gmail.com
