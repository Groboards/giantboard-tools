#!/bin/bash -x
# restart script with root privileges if not already
[ "$UID" -eq 0 ] || exec sudo "$0" "$@" ]

DISK=/dev/mmcblk0


sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${DISK}
	d # delete parition 2
	2
	n # new partition
	p # primary
	2 # second partition
	  # enter for default starting
	  # enter for default maximum size
	n # dont remove the ext4 signature
	w # write the changes
EOF

# reload partitions table
partprobe /dev/mmcblk0

# resize the rootfs to new parition size
resize2fs /dev/mmcblk0p2

#reboot
reboot
