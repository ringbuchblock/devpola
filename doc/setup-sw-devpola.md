[<< Previous Step: Raspberry Pi Basic Setup](/doc/setup-sw-basic.md)

# Setup /dev/pola Services


## (Optional) Setup Welcome Screen

If you'd like you can show an ASCII art on the display after startup. Just extend ```/etc/issue``` with the contents of [this](devpola-welcome.txt) and with ```\d``` if you also like to see the current date.

The file may then look similar to...
```bash
Raspbian GNU/Linux 8 \n \l








                 dP                                     dP          
                 88                                     88          
           .d888b88 .d8888b. dP   .dP 88d888b. .d8888b. 88 .d8888b. 
           88'  `88 88ooood8 88   d8' 88'  `88 88'  `88 88 88'  `88 
           88.  .88 88.  ... 88 .88'  88.  .88 88.  .88 88 88.  .88 
           `88888P8 `88888P' 8888P'   88Y888P' `88888P' dP `88888P8 
                                      88                            
                                      dP                            






\d
```

... and the screen like this ...

![/dev/pola welcome screen](/doc/img/welcome.JPG)


## Setup Services

Copy the /dev/pola [scripts](/scripts) (inclusive the image) to ```/home/pi/devpola``` and set proper file permissions 
```bash
$ cd
$ mkdir -p devpola
$ cd devpola
$ wget https://github.com/ringbuchblock/devpola/raw/master/scripts/devpola-config.sh
$ wget https://github.com/ringbuchblock/devpola/raw/master/scripts/devpola-main.sh
$ wget https://github.com/ringbuchblock/devpola/raw/master/scripts/devpola-upload.sh
$ wget https://github.com/ringbuchblock/devpola/raw/master/scripts/devpola.jpg
```


### Camera Control (script devpola-main.sh)

There are two buttons...
* The **shutter** button has two functions - either enabling the live preview if not already running or taking and sending a photo to the printer. The live preview is shown for a pre-defined timeout which is set to 30 seconds by default. It is configurable though via ```PREVIEW_TIMEOUT=30000 #milliseconds``` within ```devpola-config.sh```.
* The **info** button triggers a printout with some information on how to use /dev/pola.
![info text](/doc/img/info.jpg)

... and one LED which is optional but provides useful visible hints when the camera should be held still because taking a picture is in progress.

You can re-configure the default GPIO pins via editing the following constants in the config file:
```bash
# devpola-config.sh
SHUTTER=22
INFO=27
LED=17
```

Also please make sure that the correct printer's baudrate is configured:
```bash
# devpola-config.sh
BAUDRATE=19200
```

Each photo is printed along with a caption which is also configurable via ```PHOTO_CAPTION```.





### (Optional) Automatic Image Upload (script devpola-upload.sh)

/dev/pola offers an additional service for automatically uploading all the photos to a pre-defined web server via SSH. If you want to use this you first need to setup some things.

**Install Software**
```bash
# needed for qr code generation
sudo apt-get install qrencode
```

**Setup SSH**

One possibility to setup an SSH connection is to use an SSH key file.


We need to create the ssh key for the root user as the service will be running as root. The following will create a new SSH key consisting of two files in directory ```/root/.ssh```:
* ```devpola-upload```: the private key
* ```devpola-upload.pub```: the public key

```bash
# Make sure that the password stays empty as you do not want to enter the password every time you reboot /dev/pola.
$ sudo ssh-keygen 
Generating public/private rsa key pair.
Enter file in which to save the key (/root/.ssh/id_rsa): /root/.ssh/devpola-upload
Enter passphrase (empty for no passphrase): 
Enter same passphrase again:
```

In order to conveniently use this SSH key you need to add an entry within ```/root/.ssh/config```.

The ```HostName``` defines the web server to which you want to upload the photos. The ```IdentityFile``` is the path to the prior created SSH private key.
```bash
# /root/.ssh/config
Host devpola-upload
	HostName xxx.xxx.org
	User devpola
	IdentityFile ~/.ssh/devpola-upload
```

Don't forget to create the user (see ```User```) on the web server and to add the SSH public key to the web server's authorized keys.

**Enable Service**

Set ```UPLOAD_ENABLED``` to ```true``` within ```devpola-config.sh```.

By default all photos are uploaded to /dev/pola's home directory on the web server (```devpola-upload:```). If you want to use another directory you need to change ```UPLOAD_DIR``` within ```devpola-config.sh```. Please make sure to specify the path as follows ```<webserver>:<full-directory-path>``` (eg ```devpola-upload:/srv/devpola/photos```).

By default every 10 seconds a check is running which automatically uploads all new photos given that an internet connections is available. You can change that by editing ```UPLOAD_INTERVAL_SECONDS``` within ```devpola-config.sh```.



## Setup Daemons

We want to run our scripts as background services. The following explains the necessary steps:

1. Copy the systemd [units](systemd-units) to ```/etc/systemd/system```
```
$ cd
$ wget https://github.com/ringbuchblock/devpola/raw/master/systemd-units/devpola.service
$ wget https://github.com/ringbuchblock/devpola/raw/master/systemd-units/devpola-upload.service
$ chmod 755 devpola.service devpola-upload.service
$ sudo chown root:root devpola.service devpola-upload.service
$ sudo mv devpola.service devpola-upload.service /etc/systemd/system
```
2. Start and enable main /dev/pola daemon 
```
$ sudo systemctl start devpola
$ sudo systemctl enable devpola
```
