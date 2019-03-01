#!/bin/bash -ex

rfs_username="debian"
rfs_password="temppwd"
rfs_fullname="debian"
rfs_hostname="giantboard"

export LC_ALL=C
export LANGUAGE=C
export LANG=C

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
apt-get install ca-certificates sudo python3 python3-pip python3-dev python3-pil usbutils net-tools i2c-tools parted -y
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

# Enable the battery service
chmod +x /usr/bin/batt_service.sh
systemctl enable batt.service

# Make grow_sd.sh executable
chmod +x /usr/bin/grow_sd.sh

# enable usb getty
systemctl enable getty@ttyGS0.service

# Download the script to build libgpiod and build it
wget https://raw.githubusercontent.com/adafruit/Raspberry-Pi-Installer-Scripts/master/libgpiod.sh
chmod +x libgpiod.sh
./libgpiod.sh

rm libgpiod.sh

# Install blinka and circuitpython packages
pip3 install -r requirements.txt

apt-get clean

echo "Log: (chroot) chroot complete, exiting.."

exit
