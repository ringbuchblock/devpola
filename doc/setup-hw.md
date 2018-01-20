[<< Previous Step: Parts](/doc/parts.md)  

# Hardware Assembly

## Camera

You can find details on how to properly connect the camera to the Raspberry Pi directly on the [Raspberry Pi website](https://www.raspberrypi.org/documentation/usage/camera/README.md).


## Schematic

There are various options on how to wire all the parts - I'll show you one of it. Please take a look at the schematic below.

The most important part in order to avoid damage is to ensure that no other part except the thermal printer directly receives the 7.4V. We use a step-down to regulate down to 5V which is used for all other parts. Both, the Raspberry PI and the display are connected to the 5V power source. Whereas the printer is connected to the ~7V power source.

Connect the _shutter_ button to the Raspberry PI's GPIO 22, the _info_ button to GPIO 27 and the LED to GPIO 17.

The printer's yellow cable (RX) is connected to the Raspberry Pi's TX (GPIO 14). Do not connect the printer's green wire (TX).


### Exemplary Wiring with HDMI display

![/dev/pola schematic](/schematic/devpola-hdmi-schematic.jpg)

**Wiring of Kuman 3.5" HDMI MPI3508 Display**

![Kuman display](/schematic/kuman_mpi3508.jpg)


### Exemplary Wiring with GPIO display

![/dev/pola schematic](/schematic/devpola-gpio-schematic.jpg)

**Wiring of Adafruit PiTFT Plus 3.5" Display**

The display uses both, the 3.3V and the 5V power, one Ground pin and 8 additional data pins. You can pick any of the available Ground pins (the following image shows an arbitrary one). 
More detailed information about the GPIO pinout can also be found [here](https://pinout.xyz/pinout/pitft_plus_35).

![Adafruit display](/schematic/pitft_plus_3.5.png)

Further information about the GPIO pinout can be directly found at the [raspberry pi website](https://www.raspberrypi.org/documentation/usage/gpio/).

                           
[>> Next Step: Raspberry Pi Basic Setup](/doc/setup-sw-basic.md)
