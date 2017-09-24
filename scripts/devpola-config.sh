#!/bin/bash
# /dev/pola Configuration

#    devpola-config
#    Copyright (C) 2017  ringbuchblock
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.


# GPIO pin allocation
SHUTTER=22    #mandatory
INFO=27       #optional
LED=17        #optional
IP=4          #optional

# If enabled additional logs will be written.
DEBUG=false

# The printer's baud rate
BAUDRATE=19200

# The time in milliseconds for which the camera live preview is running.
PREVIEW_TIMEOUT=30000 #milliseconds

# The caption which is printed with every photo
PHOTO_CAPTION="/dev/lol @Mini Maker Faire Steyr"

# The directory which contains this script along with the /dev/pola image
HOME_DIR="/home/pi/devpola/"

# The directory where the photos get stored. If you don't want to keep them you can just change it to "/tmp/".
PHOTO_DIR="/home/pi/photos/" 

# A directory where intermediate files are stored. Preferably within /tmp directory.
TMP_DIR="/tmp/devpola/"

# The website where /dev/pola photos will be uploaded to.
URI_SHORT="devpola.devlol.org"
URI="https://"$URI_SHORT"/"

# Settings for automatic photo upload.
UPLOAD_ENABLED=false
UPLOAD_INTERVAL_SECONDS=10
UPLOAD_DIR="devpola-upload:" # this equals to /dev/pola's home directory on the server



function dlog {
  if $DEBUG; then
    echo "[DEBUG] "$1
  fi
}

function log {
  echo $1
}
