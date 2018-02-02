#!/bin/bash
# /dev/pola Main

#    devpola
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


# import settings
source /home/pi/devpola/devpola-config.sh
source /home/pi/devpola/devpola-shared.sh

# The following is used to generate a proper hash used for the photo filenames. You may not want to change this.
MAC=$(cat /sys/class/net/eth0/address)
SALT="devpola"$MAC


photo_upload_name=""

function startPreview {
  # start camera preview as background process
  dlog "start preview ("$PREVIEW_TIMEOUT" milliseconds)" 
  raspistill -f -hf -vf -t $PREVIEW_TIMEOUT -w 512 -h 384 -o $TMP_DIR/preview.jpg &
#  raspistill -p '0,0,1300,700' -hf -vf -t $PREVIEW_TIMEOUT -w 512 -h 384 -o /dev/null &
}

function killPreview {
  # kill camera process
  dlog "kill preview"
  pkill raspistill > /dev/null
}

function printing {
  #check if printer is currently printing
  if [[ $(lpstat -p) == *"idle"* ]]; then
    return 1 #false
  else 
    return 0 #true
  fi
}

function stallWhilePrinting {
  sleep 3s
  while printing; do 
    dlog "still printing"
    sleep 1s
    continue; 
  done
  dlog "printing finished"
}

function takeAndPrintPhoto {
  dlog "calculating new hash..."
  local timestamp=$(date +%s)
  local hash=`echo $timestamp$SALT | md5sum | cut -f1 -d" "`
  
  local photo_filename=$hash".jpg"
  local photo_full_path=$PHOTO_DIR$photo_filename
  photo_upload_name=$photo_filename
  
  dlog "taking photo... "$photo_full_path
  killPreview
  gpio -g write $LED 1
  raspistill -n -hf -vf -w 512 -h 384 -t 1000 -o $photo_full_path # seems thermal printer only supports width 512
  gpio -g write $LED 0
  
  dlog "sending photo to printer..."
  local subCaption
  if $DATE_PLUS_TIME; then 
    subCaption=$(date)
  else
    subCaption=$(date "+%a %e %b %Y")
  fi
  echo -e $PHOTO_CAPTION"\\n"$subCaption"\\n" > /dev/serial0
  lp -s $photo_full_path
  
  if $UPLOAD_ENABLED; then
    if $UPLOAD_HTML_ENABLED; then
      dlog "generating photo html..."
      local photo_html=$hash".html"
      local photo_full_html=$PHOTO_DIR$photo_html
      photo_upload_name=$photo_html 
      
      local escapedCaption=$(htmlEscape "${PHOTO_CAPTION}")
      local escapedSubCaption=$(htmlEscape "${subCaption}")
      $($HOME_DIR"devpola-upload-template.sh" "$escapedCaption" "$escapedSubCaption" "$photo_filename" > $photo_full_html)
    fi
  fi
  
  stallWhilePrinting
  
  if ! $UPLOAD_ENABLED; then
    rm $photo_full_path;
  fi
}

function generateAndPrintQrCode {
  dlog "generating and printing qr code..."
  
  local photo_uri=$URI$UPLOAD_FOLDER$photo_upload_name
  photo_upload_name="" #reset
  local qr_png=$TMP_DIR"qr.png"
  local qr_jpg=$TMP_DIR"qr.jpg"
  
  # generate qr code and convert to jpg (seems that png can't be printed)
  qrencode $photo_uri -o $qr_png
  convert png:$qr_png jpeg:$qr_jpg
  
  # print qr code
  echo -e "Find your /dev/pola picture \\nat "$URI_SHORT":" > /dev/serial0
  lp -s -o scaling=33 -o position=top-right $qr_jpg
  stallWhilePrinting
}

function shutterButtonPressed {
  # only take photo if preview was already running
  if pgrep raspistill; then
    takeAndPrintPhoto
    if $UPLOAD_ENABLED; then
      generateAndPrintQrCode
    fi
  fi

  # (re-)start live preview
  startPreview
}

function infoButtonPressed {
  # let's print some info text
  
  echo -e "/dev/pola\\n" > /dev/serial0

  echo -e "I am an instant camera using a \\nraspberry pi and a thermal \\nprinter.\\n\\n" > /dev/serial0
  
  lp -s -o landscape -o position=top -o scaling=90 $HOME_DIR"devpola.jpg"
  stallWhilePrinting
  

  echo -e "Try me out!\\n" > /dev/serial0
  echo -e "  1. Press 'shutter' button to \\n     enable live preview (if \\n     not already running).\\n" > /dev/serial0
  echo -e "  2. Press 'shutter' button to \\n     take a picture.\\n\\n" > /dev/serial0
  
  echo -e "Interested in more? \\nStop by @"$URI_SHORT".\\n\\n\\n" > /dev/serial0
}

function ipButtonPressed {
  # let's print the current IP
  local ip;
  internetConnectionAvailable
  if [ "$?" -eq "1" ]; then
    ip="<n/a>"
  else
    ip=$(hostname -I)
  fi
  
  local dateStr=$(date)
  echo -e "/dev/pola's IP is "$ip"\\n"$dateStr"\\n\\n\\n" > /dev/serial0
}

function main() {
  # Initialize GPIO states
  gpio -g mode  $SHUTTER up
  gpio -g mode  $INFO    up
  gpio -g mode  $LED     out
  gpio -g mode  $IP      up
  
  # prepare directories
  mkdir -p $PHOTO_DIR
  mkdir -p $TMP_DIR
  
  # prepare serial connection to printer
  stty -F /dev/serial0 $BAUDRATE

  # Flash LED on startup to indicate ready state
  for i in `seq 1 5`;
  do
    gpio -g write $LED 1
    sleep 0.2
    gpio -g write $LED 0
    sleep 0.2
  done   

  log "/dev/pola is ready!"

  enableWifi

  # main loop
  while :
  do
    # check for 'shutter' button
    if [ $(gpio -g read $SHUTTER) -eq 0 ]; then
      shutterButtonPressed
      sleep 1
      # Wait for user to release button before resuming
      while [ $(gpio -g read $SHUTTER) -eq 0 ]; do continue; done
    fi
    
    # check for 'info' button
    if [ $(gpio -g read $INFO) -eq 0 ]; then
        local ipPrinted=false
        
        # Must be held for 2+ seconds in order to trigger IP output...
        starttime=$(date +%s)
        while [ $(gpio -g read $INFO) -eq 0 ]; do
          if [ $(($(date +%s)-starttime)) -ge 2 ]; then
            ipButtonPressed
            ipPrinted=true
            sleep 2
          fi
        done
      
      if ! $ipPrinted; then
        infoButtonPressed
      fi
      sleep 1
      # Wait for user to release button before resuming
      while [ $(gpio -g read $INFO) -eq 0 ]; do continue; done
    fi
    
    # check for 'ip' button
    if [ $(gpio -g read $IP) -eq 0 ]; then
      ipButtonPressed
      sleep 1
      # Wait for user to release button before resuming
      while [ $(gpio -g read $IP) -eq 0 ]; do continue; done
    fi
  done
}

main
