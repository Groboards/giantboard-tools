#!/bin/bash -e
# restart script with root privileges if not already
[ "$UID" -eq 0 ] || exec sudo "$0" "$@" ]

IMAGE_FILE=giantboard.img
SIZE_IN_MB=850

# Create empty image file
dd if=/dev/zero of=${IMAGE_FILE} bs=1M count=${SIZE_IN_MB}

losetup /dev/loop0 ${IMAGE_FILE}

# create partition layout
sudo sfdisk /dev/loop0 <<-__EOF__
1M,48M,0xE,*
49M,,,-
__EOF__

# add the partitions to loop0
# unmount and remount so losetup can rescan the paritions
losetup -D
losetup --partscan /dev/loop0 ${IMAGE_FILE}

# Create boot partition 
mkfs.vfat -F 16 /dev/loop0p1 -n BOOT

# create rootfs partition
mkfs.ext4 /dev/loop0p2 -L rootfs

# make dirs for mounting
mkdir -p /media/boot/
mkdir -p /media/rootfs/

# mount the dirs
mount /dev/loop0p1 /media/boot/
mount /dev/loop0p2 /media/rootfs/

# copy at91 bootloader and u-boot
cp -v ./at91bootstrap/binaries/sama5d27_som1_ek-sdcardboot-uboot-3.8.10.bin /media/boot/BOOT.BIN
cp -v ./u-boot/u-boot.bin /media/boot/

# copy the rootfs
cp -av output/rootfs/ /media/
sync
chown root:root /media/rootfs/
chmod 755 /media/rootfs/

# copy kernel image
cp -v output/build/linux/arch/arm/boot/zImage /media/boot/zImage

# copy kernel dtbs
mkdir -p /media/boot/dtbs/
cp -v output/build/linux/arch/arm/boot/dts/at91-sama5d27_giantboard.dtb /media/boot/dtbs/

# copy kernel modules
cp -av output/modules/lib/ /media/rootfs/

# sync and unmount
sync
umount /media/boot
umount /media/rootfs
losetup -D
