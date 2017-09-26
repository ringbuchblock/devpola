# Basic Raspberry Pi Setup

Download the [latest raspian image](https://www.raspberrypi.org/downloads/raspbian/) (no desktop needed) and write it to the SD card.

Next, we need to make some general configurations using the [Raspberry Pi configuration tool](https://www.raspberrypi.org/documentation/configuration/raspi-config.md).
```bash
sudo raspi-config
```
Mandatory Settings:
* ```Expand Filesystem```: this ensures that all of the SD card storage is available to the OS
* ```Enable Camera```: this enables the Raspberry Pi to work with the camera
* Disable the serial console via ```Advanced Options > Serial```

Optional Settings:
* ```Change User Password```
* ```Internationalisation Options > Change Keyboard Layout```
* Set hostname via ```Advanced Optons > Hostname```
* Enable SSH via ```Advanced Options > SSH```
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
raspistill -f -t 1000 -o /tmp/test.jpg
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
sudo lpadmin -p ZJ-58 -E -v serial:/dev/ttyAMA0?baud=<BAUDRATE> -m zjiang/ZJ-58.ppd
sudo lpoptions -d ZJ-58
```

Optionally test the printer:
1. ensure that the printer is properly connected (see Hardware section)
2. send a sample text to the printer
```
stty -F /dev/AMA0 <BAUDRATE>
echo -e "This is a test.\\n\\n\\n" > /dev/AMA0
```

Interested in more? There's a nice [Adafruit tutorial](https://learn.adafruit.com/networked-thermal-printer-using-cups-and-raspberry-pi?view=all).
