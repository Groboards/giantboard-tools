#!/bin/bash -ex

rfs_username="debian"
rfs_password="temppwd"
rfs_fullname="debian"
rfs_hostname="giantboard"

export LC_ALL=C
export LANGUAGE=C
export LANG=C

# blinka python libs array
declare -a blinka_libs=("74hc595"
						"ads1x15"
						"adt7410"
						"adxl34x"
						"am2320"
						"amg88xx"
						"apds9960"
						"as726x"
						"bme280"
						"bme680"
						"bmp280"
						"bmp3xx"
						"bno055"
						"bluefruitspi"
						"cap1188"
						"ccs811"
						"charlcd"
						"crickit"
						"dht"
						"drv2605"
						"ds1307"
						"ds18x20"
						"ds2413"
						"ds3231"
						"dotstar"
						"epd"
						"esp-atcontrol"
						"fram"
						"fxas21002c"
						"fxos8700"
						"fingerprint"
						"focaltouch"
						"gps"
						"hcsr04"
						"ht16k33"
						"htu21d"
						"ina219"
						"irremote"
						"is31fl3731"
						"l3gd20"
						"lidarlite"
						"lis3dh"
						"lsm303"
						"lsm9ds0"
						"lsm9ds1"
						"max31855"
						"max31856"
						"max31865"
						"max7219"
						"max9744"
						"mcp230xx"
						"mcp3xxx"
						"mcp4725"
						"mcp9808"
						"mlx90393"
						"mlx90614"
						"mma8451"
						"mpl115a2"
						"mpl3115a2"
						"mpr121"
						"mprls"
						"matrixkeypad"
						"neopixel"
						"neotrellis"
						"pca9685"
						"pcd8544"
						"pcf8523"
						"pn532"
						"pixie"
						"rfm69"
						"rfm9x"
						"rgb-display"
						"sd"
						"sgp30"
						"sht31d"
						"si4713"
						"si5351"
						"si7021"
						"ssd1306"
						"stmpe610"
						"seesaw"
						"sharpmemorydisplay"
						"tca9548a"
						"tcs34725"
						"tfmini"
						"tlc5947"
						"tlc59711"
						"tmp006"
						"tmp007"
						"tsl2561"
						"tsl2591"
						"thermal-printer"
						"thermistor"
						"trellism4"
						"trellis"
						"us100"
						"vc0706"
						"vcnl4010"
						"veml6070"
						"veml6075"
						"vl53l0x"
						"vl6180x"
						"vs1053"
						"ws2801")

add_user () {
	echo "Log: (chroot): add_user"
	groupadd -r admin || true
	groupadd -r spi || true
	cat /etc/group | grep ^i2c || groupadd -r i2c || true
	cat /etc/group | grep ^kmem || groupadd -r kmem || true
	cat /etc/group | grep ^netdev || groupadd -r netdev || true
	cat /etc/group | grep ^systemd-journal || groupadd -r systemd-journal || true
	cat /etc/group | grep ^gpio || groupadd -r gpio || true
	cat /etc/group | grep ^pwm || groupadd -r pwm || true
	cat /etc/group | grep ^eqep || groupadd -r eqep || true
	echo "KERNEL==\"hidraw*\", GROUP=\"plugdev\", MODE=\"0660\"" > /etc/udev/rules.d/50-hidraw.rules
	echo "KERNEL==\"spidev*\", GROUP=\"spi\", MODE=\"0660\"" > /etc/udev/rules.d/50-spi.rules
	echo "#SUBSYSTEM==\"uio\", SYMLINK+=\"uio/%s{device/of_node/uio-alias}\"" > /etc/udev/rules.d/uio.rules
	echo "SUBSYSTEM==\"uio\", GROUP=\"users\", MODE=\"0660\"" >> /etc/udev/rules.d/uio.rules
	default_groups="admin,adm,dialout,gpio,pwm,eqep,i2c,kmem,spi,cdrom,floppy,audio,dip,video,netdev,plugdev,users,systemd-journal"


	echo "Log: (chroot) adding admin group to /etc/sudoers.d/admin"
	echo "Defaults	env_keep += \"NODE_PATH\"" >/etc/sudoers.d/admin
	echo "%admin ALL=(ALL:ALL) ALL" >>/etc/sudoers.d/admin
	chmod 0440 /etc/sudoers.d/admin
	
	pass_crypt=$(perl -le "print crypt("${rfs_password}", "groboards")")
	useradd -G "${default_groups}" -s /bin/bash -m -p ${pass_crypt} -c "${rfs_fullname}" ${rfs_username}
	grep ${rfs_username} /etc/passwd
	mkdir -p /home/${rfs_username}/bin
	chown ${rfs_username}:${rfs_username} /home/${rfs_username}/bin
	
	#set root password
	passwd <<-EOF
	root
	root
	EOF

	sed -i -e 's:#EXTRA_GROUPS:EXTRA_GROUPS:g' /etc/adduser.conf
	sed -i -e 's:dialout:dialout i2c spi:g' /etc/adduser.conf
	sed -i -e 's:#ADD_EXTRA_GROUPS:ADD_EXTRA_GROUPS:g' /etc/adduser.conf

}

# Add sources
cat <<EOT > /etc/apt/sources.list
deb http://ftp.debian.org/debian stretch main contrib non-free
deb-src http://ftp.debian.org/debian stretch main contrib non-free
deb http://ftp.debian.org/debian stretch-updates main contrib non-free
deb-src http://ftp.debian.org/debian stretch-updates main contrib non-free
deb http://security.debian.org/debian-security stretch/updates main contrib non-free
deb-src http://security.debian.org/debian-security stretch/updates main contrib non-free
EOT

# Update and install stuff and things
apt-get update
apt-get install ca-certificates sudo python3 python3-pip python3-dev usbutils net-tools parted -y
pip3 install wheel

# Setup the fstab for the microSD
sh -c "echo '/dev/mmcblk0p2  /  auto  errors=remount-ro  0  1' >> /etc/fstab"
sh -c "echo '/dev/mmcblk0p1  /boot/uboot  auto  defaults  0  2' >> /etc/fstab"

echo ${rfs_hostname} > /etc/hostname

# Add the user, set up groups and permissions
add_user

cat > /etc/motd <<'EOF'
   _____ _             _     ____                      _
  / ____(_)           | |   |  _ \                    | |
 | |  __ _  __ _ _ __ | |_  | |_) | ___   __ _ _ __ __| |
 | | |_ | |/ _` | '_ \| __| |  _ < / _ \ / _` | '__/ _` |
 | |__| | | (_| | | | | |_  | |_) | (_) | (_| | | | (_| |
  \_____|_|\__,_|_| |_|\__| |____/ \___/ \__,_|_|  \__,_|

EOF

sh -c "echo '127.0.0.1       giantboard' >> /etc/hosts"

systemctl enable getty@ttyGS0.service

# Download the script to build libgpiod and build it
wget https://raw.githubusercontent.com/adafruit/Raspberry-Pi-Installer-Scripts/master/libgpiod.sh
chmod +x libgpiod.sh
./libgpiod.sh

rm libgpiod.sh

# Install blinka
pip3 install adafruit-blinka
pip3 install adafruit-io

# Install all the libs listed in the blinka_libs array
for i in "${blinka_libs[@]}"
do
   pip3 install adafruit-circuitpython-"$i"
done

apt-get clean

echo "Log: (chroot) chroot complete, exiting.."

exit
