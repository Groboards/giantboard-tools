#!/bin/bash -e
# restart script with root privileges if not already
[ "$UID" -eq 0 ] || exec sudo "$0" "$@" ]

patch_dir="$(pwd)/patches/"
output_dir="$(pwd)/output"
at91boot_bin="${output_dir}/at91bootstrap"
uboot_bin="${output_dir}/u-boot"
images_dir="${output_dir}/images"
modules_dir="${output_dir}/modules"
rootfs_dir="${output_dir}/rootfs"
overlays_dir="${output_dir}/overlays"


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
cp -v ${at91boot_bin}/BOOT.BIN /media/boot/BOOT.BIN
cp -v ${uboot_bin}/u-boot.bin /media/boot/

# copy the rootfs
cp -av ${rootfs_dir} /media/
sync
chown root:root /media/rootfs/
chmod 755 /media/rootfs/

# copy kernel image
cp -v ${images_dir}/zImage /media/boot/zImage

# copy kernel dtbs
mkdir -p /media/boot/dtbs/
cp -v ${images_dir}/at91-sama5d27_giantboard.dtb /media/boot/dtbs/

# copy kernel modules
cp -av ${modules_dir}/lib/ /media/rootfs/

# copy overlays
mkdir -p /media/boot/overlays/
cp -av ${overlays_dir}/ /media/boot/

# copy the default uEnv.txt
cp -v ${patch_dir}/uEnv.txt /media/boot/

# sync and unmount
sync
umount /media/boot
umount /media/rootfs
losetup -D

echo "done making ${IMAGE_FILE}"
