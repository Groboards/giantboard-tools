#!/bin/bash -ex

export LC_ALL=C
export LANGUAGE=C
export LANG=C


# Update and install stuff and things
apt-get update && \
apt-get install -y ca-certificates sudo python3 \
				   python3-setuptools python3-pip \
				   python3-dev python3-pil wpasupplicant \
				   hostapd connman


# Install wheel now for other packages
pip3 install wheel


# Setup the fstab for the microSD
sh -c "echo '/dev/mmcblk0p2  /  auto  errors=remount-ro  0  1' >> /etc/fstab"
sh -c "echo '/dev/mmcblk0p1  /boot/uboot  auto  defaults  0  2' >> /etc/fstab"


# Enable the battery service
if (systemctl -q is-enabled batt.service); then
	echo "Log: (chroot) battery service already enabled"
else
	echo "Log: (chroot) enabling battery service"
	chmod +x /usr/bin/batt_service.sh
	systemctl enable batt.service
fi


# Enable the gadget service
if (systemctl -q is-enabled usbgadget-serial-eth-ms.service); then
	echo "Log: (chroot) usb gadget already enabled"
else
	echo "Log: (chroot) enabling usbgadget service"
	chmod +x /usr/bin/usbgadget-serial-eth-ms
	systemctl enable usbgadget-serial-eth-ms.service
fi


# Make grow_sd.sh executable
chmod +x /usr/bin/grow_sd.sh


# Download the script to build libgpiod and build it
wget https://raw.githubusercontent.com/adafruit/Raspberry-Pi-Installer-Scripts/master/libgpiod.sh
chmod +x libgpiod.sh
./libgpiod.sh
rm libgpiod.sh


# Add wifi firmware
wget https://github.com/linux4wilc/firmware/raw/master/wilc1000_wifi_firmware.bin
mkdir -p /lib/firmware/mchp
mv wilc1000_wifi_firmware.bin /lib/firmware/mchp


# Install blinka and circuitpython packages
pip3 install -r requirements.txt


# Clean up
apt-get clean

echo "Log: (chroot) chroot complete, exiting.."

exit
