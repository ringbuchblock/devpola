#!/bin/bash
# /dev/pola Upload Template

#    devpola-upload-template
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


#define parameters which are passed in.
CAPTION=$1
SUB_CAPTION=$2
IMG_URL=$3

#define the template.
cat << EOF
<html>

<head>
  <title>/dev/pola</title>
  <link rel="stylesheet" media="screen" href="https://devpola.devlol.org/ext/default.css"/>
</head>

<body>
  <h1><a href="https://devpola.devlol.org/" target="_blank">/dev/pola</a></h1>

  <div id="photo">
    <div class="caption">$CAPTION</div>
    <div class="subcaption">$SUB_CAPTION</div>
    <a href="$IMG_URL" download>
      <img class="info" src="$IMG_URL" />
    </a>
    <p class="disclaimer">Please note that your photo will be deleted after approximately a month. Thus, please download it if you want to keep it.</p>
  </div><!-- photo -->

  <div class="info">Wanna build a /dev/pola of your own? Stop by at <a href="https://github.com/ringbuchblock/devpola" target="_blank">github</a>.</div>        
</body>

</html>

EOF
