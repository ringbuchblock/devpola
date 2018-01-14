#!/bin/bash
# /dev/pola Shared Functions

#    devpola-shared
#    Copyright (C) 2018  ringbuchblock
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


function dlog {
  if $DEBUG; then
    echo "[DEBUG] "$1
  fi
}

function log {
  echo $1
}

function htmlEscape {
  # & gets &amp;
  # < gets &lt;
  # > gets &gt;,
  # " gets &quot;
  # ' gets &#39;
  #   gets &nbsp;
  # \\n gets <br/>
  echo "$1" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g; s/ /\&nbsp;/g; s:\\n:<br/>:g' 
}

function internetConnectionAvailable {
  if ping -q -c 1 -W 1 8.8.8.8 >/dev/null; then
    return 0 #true
  else
    return 1
  fi
}

function wifiConnectionAvailable {
  if [ $(cat /sys/class/net/wlan0/carrier) -eq "1" ]; then
    return 0 #true
  else
    return 1
  fi
}

function disableWifi {
  dlog "disabling wifi"
  sudo ifconfig wlan0 down
  #sudo ifdown wlan0
}

function enableWifi {
  dlog "enabling wifi"
  sudo ifconfig wlan0 up
  #sudo ifup wlan0
}

function toggleWifi {
  wifiConnectionAvailable
  if [ "$?" -eq "0" ]; then
    disableWifi
  else 
    enableWifi
  fi
}
