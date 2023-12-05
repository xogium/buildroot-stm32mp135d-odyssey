# External buildroot tree for STM32MP135D ODYSSEY #
This external tree is to be used in conjunction with upstream buildroot, 
version 2023.02 or later. Previous versions might work, but are not supported, 
nor recommended.

## Features ##
This external tree provides the following:
* A single stm32mp135d_odyssey_defconfig which builds a minimal and generic 
system consisting of tf-a, optee, u-boot, and the linux kernel for the boot 
chain. The userspace is minimal and consists of a simple busybox init system 
and shell.
	* This system can be used in the following ways:
		* Written and booted from the eMMC (if your hardware 
		has it)
		* Written and booted from a micro sd card.
		* Booted over NFS.
* A post-build script is used to provide an easily writable bootloader image 
for the eMMC. It combines -tf-a and FIP image together in a single file, meant 
to be written using DFU, into the boot regions of said eMMC.
* A genimage configuration generates two disk images:
	* emmc.img contains an u-boot-env partition to easily store the u-boot 
environment into, along with the rootfs. It is expected that the bootloader be 
stored into the eMMC boot regions via DFU.
	* sdcard.img is comprised of two copies of tf-a into fsbl1 and fsbl2 
partitions, respectively, along with one single fip partition which contains 
the FIP image. There is also an u-boot-env partition the same as in emmc.img, 
along with a single rootfs.
* The external tree provides support for [Grove Base Hat for Raspberry Pi](https://wiki.seeedstudio.com/Grove_Base_Hat_for_Raspberry_Pi/) as a start to build your projects.

## How to build ##
### Preparations ###
First, you must ensure all the buildroot dependencies are met. Please 
refer to [The buildroot user manual, chapter 2: System 
requirements](https://buildroot.org/downloads/manual/manual.html#requirement). 
[snagboot](https://github.com/bootlin/snagboot) is also required if you 
wish to do eMMC and or NFS boot (see below). Please follow the 
instructions given by bootlin in their git repository, setting up 
snagboot is out of scope of this guide.

Then, setup the required source code, as follows:
```
wget https://buildroot.org/downloads/buildroot-2023.02.5.tar.gz
tar -xf buildroot-2023.02.5.tar.gz
mv buildroot-2023.02.5 buildroot
git clone https://github.com/xogium/buildroot-stm32mp135d-odyssey
```

### Building ###
Once the source code has been set up correctly, you can proceed with the 
build:
```
cd buildroot
make BR2_EXTERNAL=/absolute/path/to/buildroot-stm32mp135d-odyssey stm32mp135d_odyssey_defconfig
make
```

If everything goes well, you should now have a successfully built 
system in the output/images directory of your buildroot tree.
```
ls -1 output/images
combined-tf-a-and-fip.img
emmc.img
fip.bin
rootfs.ext2
rootfs.ext4
rootfs.tar
sdcard.img
stm32mp135d-odyssey-grove.dtb
tee.bin
tee-header_v2.bin
tee-pageable_v2.bin
tee-pager_v2.bin
tf-a-stm32mp135d-odyssey.stm32
u-boot.dtb
u-boot-nodtb.bin
zImage
```

### How to use the system ###
#### eMMC boot ####
Remove the middle boot jumper to be sure DFU mode is active. Connect an
usb to serial console cable, and apply power
to your board over usb-c. Make sure to open the serial console using 
minicom or another similar program, you
will need it.

Then, execute the following command from the snagboot package and be
prepared to interrupt the boot sequence when reaching u-boot, by
pressing any key in the serial console window:
```
cd output/images
snagrecover -s stm32mp13 -f ../../board/stm32mp135d-odyssey/utilities/stm32mp1-stm32mp135d-odyssey.yaml
```

Once at the u-boot prompt, type the following to enable the eMMC boot 
partition: ```mmc partconf 1 1 1 1```. This enables the first eMMC boot 
partition and ensure it is possible to boot from it, by modifying ext 
csd register 179. Then, type ```dfu 0``` to expose all the DFU alt 
settings to your host machine, including the eMMC boot regions. They can 
be listed using the dfu-util command:
```
dfu-util -l
Found DFU: [0483:df11] ver=0200, devnum=7, cfg=1, intf=0, path="3-3", alt=4, name="mmc1_boot2", serial="0021001A3232510937393835"
Found DFU: [0483:df11] ver=0200, devnum=7, cfg=1, intf=0, path="3-3", alt=3, name="mmc1_boot1", serial="0021001A3232510937393835"
...
```

Then, use the snagflash tool to write the combined bootloader image into 
both boot regions:
```
snagflash -P dfu -p 0483:df11 --dfu-keep -D 3:combined-tf-a-and-fip.img
snagflash -P dfu -p 0483:df11 -D 4:combined-tf-a-and-fip.img
```

Once this is done, reset the board and confirm that the eMMC boot now 
works as expected by putting the middle boot jumper back onto the board. 
It will error out at booting from mmc1 partition 0 given the user area 
is blank, but this is normal at this stage.

When you're back at the u-boot prompt again, type ```ums 0 1``` to 
expose the user area of the eMMC as a usb mass storage device to your 
host machine. Use lsblk to determine which device node it was assigned, 
and replace sdX in the following command with the appropriate device 
node. Double check to ensure you will write on the correct device as it 
will be wiped entirely!
```snagflash -P ums -s emmc.img -b /dev/sdX```

When the writing has completed, press ctrl+c at the u-boot prompt to 
terminate the usb mass storage mode. Then, reset your board again, and 
confirm that it is now booting linux and that you get a login prompt. 
Log in with the root user and the password 'grove'.

#### Micro sd card boot ####
If you wish to burn the system onto a micro sd card, please proceed as 
follows, replacing sdX with the appropriate device node:
```sudo dd if=output/images/sdcard.img of=/dev/sdX bs=4M conv=fsync```
Where sdX corresponds to the micro sd card device node. Refers to 
the output of lsblk command to make sure you get the correct device 
node! Otherwise, data loss will occure, as this erases the entire content of 
the target device.

When the micro sd card has been successfully written to, insert it into 
the micro sd socket of the STM32MP135D ODYSSEY board, and apply power 
via usb-c or PoE. The system will print to the serial console by 
default, so make sure to connect a usb to serial console cable. Log in 
with the user root and the password 'grove'.

#### Nfs boot ####
To boot the system via NFS, please ensure to set up your /etc/exports as 
demonstrated, replacing the subnet / allowed ip addresses as needed, 
doing the same for the exported paths:
```
/srv/nfs 192.168.1.0/24(rw,sync,crossmnt,fsid=0)
/srv/nfs/stm32mp135d 192.168.1.0/24(rw,nohide,insecure,no_subtree_check,async,no_root_squash)
```

Also make sure your nfs server configuration enables UDP mode, like so:
```
/etc/nfs.conf
[nfsd]
...
udp=y
```

Remove the middle boot jumper to be sure DFU mode is active. Connect an 
usb to serial console cable, an ethernet cable to eth1 and apply power 
to your board. Make sure to open the serial console using minicom or another 
similar program, you 
will need it.

Then, execute the following command from the snagboot package and be 
prepared to interrupt the boot sequence when reaching u-boot, by 
pressing any key in the serial console window:
```
cd output/images
snagrecover -s stm32mp13 -f ../../board/stm32mp135d-odyssey/utilities/stm32mp1-stm32mp135d-odyssey.yaml
```

Once you're at the u-boot prompt, you can boot over nfs by doing the 
following:
```
setenv eth1addr 2c:f7:f1:30:2b:62
setenv ethaddr 2c:f7:f1:30:2b:62
dhcp
nfs ${kernel_addr_r} 192.168.1.92:/srv/nfs/stm32mp135d/boot/zImage
nfs ${fdt_addr_r} 192.168.1.92:/srv/nfs/stm32mp135d/boot/stm32mp135d-odyssey-grove.dtb
setenv bootargs root=/dev/nfs rootfstype=nfs ip=dhcp nfsroot=192.168.1.92:/srv/nfs/stm32mp135d,tcp,v3 rw quiet console=ttySTM0,115200n8 earlycon
bootz ${kernel_addr_r} - ${fdt_addr_r}
```
Where 192.168.1.92 in this example is the machine hosting the nfs 
server. The MAC address set is also an example and not to be used in the 
real world. It is required due to having no MAC addresses defined in the 
OTP, but can be stored semi-permanently in the EEPROM (see below). Log 
in with the user root and no password.

## EEPROM ##
### Layout ###
The current implementation to read MAC addresses from the EEPROM is 
expecting the first one to start at offset 0 and have a length of 6 
bytes. The second MAC must be stored at offset 0x10, and also have a 
length of 6 bytes.

For storing the u-boot environment into the EEPROM if you wish to do so, 
please ensure that the environment begins on a new page boundary. Pages 
are 64 bytes in size. For example, you could set the environment offset 
to 0x40, the size remaining at 0x2000, and redundant offset to 0x2080. 
Here's an example u-boot config fragment:
```
CONFIG_ENV_IS_IN_EEPROM=y
CONFIG_ENV_OFFSET=0x40
CONFIG_ENV_OFFSET_REDUND=0x2080
CONFIG_I2C_EEPROM=y
CONFIG_SYS_I2C_EEPROM_ADDR=0x50
CONFIG_NVMEM=y
```

To apply it, run ```make menuconfig``` in the toplevel buildroot 
directory. Go to the bootloaders menu, scroll down to u-boot and modify 
the additional config fragments path, for example by inputting 
```$(BR2_EXTERNAL_STM32MP135D_ODYSSEY_PATH)/board/stm32mp135d-odyssey/configs/uboot.config```.

Then, please do a rebuild using ```make clean && make```.

Ultimately the layout is free for you to use, except for the MAC 
addresses location and length.

### How to use the EEPROM ###
To make use of the EEPROM on your board, you get access to it as a nvmem 
device, in both u-boot and linux. For example, lets write a MAC address 
in it:
```printf '\x2c\xf7\xf1\30\x2b\x62'|dd of=/sys/bus/nvmem/devices/0-00501/nvmem bs=1```

To store a second MAC address, do like so: ```printf '\x2c\xf7\xf1\30\x2b\x63'|dd of=/sys/bus/nvmem/devices/0-00501/nvmem bs=1 seek=16```

## Networking and SSH ##

Linux will boot and acquire an IP over Ethernet using DHCP. You can then log in
to your device using this command:

```
ssh root@192.168.1.92
```

Replace 192.168.1.92 with your device's IP. You can usually find this in your
router control page.

Once logged in you can change the password using the ```passwd``` command.

Alternatively you can disable SSH access by setting
```BR2_PACKAGE_DROPBEAR=y``` to ```BR2_PACKAGE_DROPBEAR=n``` in your buildroot
```.config``` file, then rebuilding and re-flashing your board.

## Grove support ##

As mentioned earlier this external tree provides support for Seeed Studio's
Grove Base Hat as well as some helpful utilities and examples applications.

This consists of the following features:

- A device tree enabling PWM and I2C on the Pi header
- Symbolic links in /dev for Pi compatibility
- A port of mraa with pin mappings for the Odyssey
- An install of Python and the grove.py package
- Packaging and porting examples for some sensors
- Low level tools for direct GPIO and I2C access

Code written using standard Linux interfaces should require minimal porting
when moving from other Linux Grove boards to this one.

Here are some commands to get you started:

- i2cdetect, i2cdump, i2cget, i2cset, i2ctransfer
- gpiodetect, gpiofind, gpioget, gpioinfo, gpiomon, gpioset
- mraa-gpio, mraa-i2c, mraa-uart
- bma456_test, test_ak09918, test_bmi088, test_icm20600
- dht_simpleread, sht4x
- Typing grove_ then pressing the tab key will give you a full list of grove commands

If you have a buzzer, make sure to attach it to the PWM port and listen for a
beep on boot!

Remember to power off the board when connecting and disconnecting components to
your Grove hat!

## Modifying and extending Buildroot ##

Buildroot is a fantastic system for creating embedded Linux systems. If you
plan to use this system I highly recommend reading [the Buildroot user
manual](https://buildroot.org/downloads/manual/manual.html).

That said, here are some helpful tips to get you started:

- 'make menuconfig' will let you add or remove packages
- 'make savedefconfig' updates the configs/ file in this repository
- strace and kernel tracing are enabled by default for this tree
- Put files in rootfs_overlay/etc/init.d/ and mark them as executable to run them on boot
- Put files in rootfs_overlay/usr/bin and mark them as executable to run them from a shell
- Look in the packages directory for examples of packaging C and python packages

If you have questions about this tree or find bugs, please open an issue in the
GitHub repository.
