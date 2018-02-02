[<< Previous Step: Hardware Assembly](/doc/setup-hw.md)

# Basic Raspberry Pi Setup

Download the [latest raspian image](https://www.raspberrypi.org/downloads/raspbian/) (no desktop needed) and write it to the SD card.

Next, we need to make some general configurations using the [Raspberry Pi configuration tool](https://www.raspberrypi.org/documentation/configuration/raspi-config.md).
```bash
sudo raspi-config
```
Mandatory Settings:
* ```Advanced Options > Expand Filesystem```: this ensures that all of the SD card storage is available to the OS
* ```Interfacing Options > Camera```: enable the Raspberry Pi to work with the camera
* Disable login shell and enable serial port hardware via ```Interfacing Options > Serial```

Optional Settings:
* ```Change User Password```
* ```Localisation Options > Change Keyboard Layout```
* Set hostname via ```Network Optons > Hostname```
* Enable SSH via ```Interfacing Options > SSH```
* Disable overscan via ```Advanced Options > Overscan```

When you're done reboot the system and ensure that the raspberry is connected to the Internet for the following steps.

## Update and Upgrade the System

```bash
sudo apt-get update
sudo apt-get upgrade
```

## Test Camera

Type the following command in the shell. If you see a live preview on your screen the camera works properly.
```bash
# show a 1 second live preview and store image as /tmp/test.jpg
raspistill -f -t 3000 -o /tmp/test.jpg
```

Interested in more? Visit the the [Raspberry Pi website](https://www.raspberrypi.org/documentation/usage/camera/raspicam/README.md).

## Install Printer Support

Install some basic packages:
```bash
sudo apt-get install git cups wiringpi build-essential libcups2-dev libcupsimage2-dev
```

Install raster filter for CUPS:
```bash
cd
git clone https://github.com/adafruit/zj-58
cd zj-58
make
sudo ./install
```

Add printer to the CUPS system and set it as default:
```bash
# <BAUDRATE> needs to be replaced by actual printer's baud rate
sudo lpadmin -p ZJ-58 -E -v serial:/dev/serial0?baud=<BAUDRATE> -m zjiang/ZJ-58.ppd
sudo lpoptions -d ZJ-58
```

Optionally test the printer:
1. ensure that the printer is properly connected (see Hardware section)
2. send a sample text to the printer
```
stty -F /dev/serial0 <BAUDRATE>
echo -e "This is a test.\\n\\n\\n" > /dev/serial0
```

Interested in more? There's a nice [Adafruit tutorial](https://learn.adafruit.com/networked-thermal-printer-using-cups-and-raspberry-pi?view=all).

## Display

In case you use an HDMI display you do not need to install anything further because HDMI connection works out of the box.

GPIO displays, however, need some further installation steps which are depending on the display's model. I'll cover one model which I've used so far.

### Setup Adafruit PiTFT Plus 3.5"

In case you are also using an [Adafruit PiTFT Plus 3.5"](https://www.adafruit.com/product/2441) please follow the steps described [here](https://learn.adafruit.com/running-opengl-based-games-and-emulators-on-adafruit-pitft-displays/rescaling?view=all#pitft-setup) or the summary below.

```bash
# download a script provided by Adafruit which helps you setting up the display
$ cd
$ curl -O https://raw.githubusercontent.com/adafruit/Raspberry-Pi-Installer-Scripts/master/pitft-fbcp.sh
```

```bash
# run Adafruit's script
$ sudo bash pitft-fbcp.sh

This script enables basic PiTFT display
support for portable gaming, etc.  Does
not cover X11, touchscreen or buttons
(see adafruit-pitft-helper for those).
HDMI output is set to PiTFT resolution,
not all monitors support this, PiTFT
may be only display after reboot.
Run time ~5 minutes. Reboot required.
 
CONTINUE? [y/N] y
 
Select project:
1. PiGRRL 2
2. Pocket PiGRRL
3. PiGRRL Zero
4. Configure options manually
 
SELECT 1-4: 4
 
Select display type:
1. PiTFT 2.2" HAT
2. PiTFT / PiTFT Plus resistive 2.4-3.2"
3. PiTFT / PiTFT Plus 2.8" capacitive
4. PiTFT / PiTFT Plus 3.5"
 
SELECT 1-4: 4
 
HDMI rotation:
1. Normal (landscape)
2. 90° clockwise (portrait)
3. 180° (landscape)
4. 90° counterclockwise (portrait)
 
SELECT 1-4: 1
 
TFT (MADCTL) rotation:
1. 0
2. 90
3. 180
4. 270
 
SELECT 1-4: 4
 
Device: pitft35-resistive
HDMI framebuffer rotate: 0
TFT MADCTL rotate: 270
 
CONTINUE? [y/N] y
```

Reboot your pi:
```bash
sudo reboot
```

In case your display still is black try the following and reboot again:
```bash
curl -SLs https://apt.adafruit.com/add-pin | sudo bash
sudo apt-get install adafruit-pitft-helper
sudo reboot
```


[>> Next Step: Deploying /dev/pola](/doc/setup-sw-devpola.md)
