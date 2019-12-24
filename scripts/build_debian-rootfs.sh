#!/bin/bash                                                                                                                                 
# restart script with root privileges if not already
[ "$UID" -eq 0 ] || exec sudo "$0" "$@" ]

output_dir="$(pwd)/output"
patch_dir="$(pwd)/patches/rootfs"
chroot_user_file="$(pwd)/scripts/chroot_user.sh"
rootfs_dir="${output_dir}/rootfs"
min_rootfs_dir="${output_dir}/min_rootfs"

# build min debian rootfs if cached build doesn't exist
if [ ! -d "${min_rootfs_dir}" ]; then
	echo "Log: (debootstrap) no minimum rootfs found. Building minimum rootfs to save time in the future."
	mkdir -p ${min_rootfs_dir}
	debootstrap \
		--include usbutils,net-tools,i2c-tools,parted,sudo \
		--arch armhf \
		--foreign stretch \
		${min_rootfs_dir} \
		http://ftp.us.debian.org/debian/
	
	
	cp /usr/bin/qemu-arm-static ${min_rootfs_dir}/usr/bin/
	cp ${patch_dir}/grow_sd.sh ${min_rootfs_dir}/usr/bin/
	cp scripts/chroot_min.sh ${min_rootfs_dir}
		
	mkdir -p ${min_rootfs_dir}/run
	chmod -R 755 ${min_rootfs_dir}/run
	mount -t tmpfs run "${min_rootfs_dir}/run"

	chroot ${min_rootfs_dir} /debootstrap/debootstrap --second-stage
	
	mount -t sysfs sysfs "${min_rootfs_dir}/sys"
	mount -t proc proc "${min_rootfs_dir}/proc"
	mkdir -p ${min_rootfs_dir}/dev/pts
	mount -t devpts devpts "${min_rootfs_dir}/dev/pts"

	chroot "${min_rootfs_dir}" /bin/bash -e chroot_min.sh
	rm ${min_rootfs_dir}/chroot_min.sh
	sync

	umount -fl "${min_rootfs_dir}/dev/pts"
	umount -fl "${min_rootfs_dir}/proc"
	umount -fl "${min_rootfs_dir}/sys"
	umount -fl "${min_rootfs_dir}/run"

	rm ${min_rootfs_dir}/usr/bin/qemu-arm-static
	
	echo "Log: (debootstrap) minimum rootfs build complete."
fi

# copy the cached debian rootfs build to the main rootfs folder
if [ ! -d "${rootfs_dir}" ]; then
	mkdir -p ${rootfs_dir}
	cp -rp ${min_rootfs_dir}/. ${rootfs_dir}
fi

# Add chroot script
cp scripts/chroot.sh ${rootfs_dir}

# Add requirements.txt to install all circuitpython packages
cp ${patch_dir}/requirements.txt ${rootfs_dir}

# Add qemu-arm-static to rootfs
cp /usr/bin/qemu-arm-static ${rootfs_dir}/usr/bin/

# Add services
mkdir -p ${rootfs_dir}/lib/systemd/system/

cp ${patch_dir}/usbgadget-serial ${rootfs_dir}/usr/bin/
cp ${patch_dir}/usbgadget-serial.service ${rootfs_dir}/lib/systemd/system/

cp ${patch_dir}/usbgadget-serial-eth ${rootfs_dir}/usr/bin/
cp ${patch_dir}/usbgadget-serial-eth.service ${rootfs_dir}/lib/systemd/system/

cp ${patch_dir}/usbgadget-serial-eth-ms ${rootfs_dir}/usr/bin/
cp ${patch_dir}/usbgadget-serial-eth-ms.service ${rootfs_dir}/lib/systemd/system/

cp ${patch_dir}/batt.service ${rootfs_dir}/lib/systemd/system
cp ${patch_dir}/batt_service.sh ${rootfs_dir}/usr/bin/


if [ ! -d "${rootfs_dir}/run" ]; then
	mkdir -p ${rootfs_dir}/run
	chmod -R 755 ${rootfs_dir}/run
fi

mount -t tmpfs run "${rootfs_dir}/run"
mount -t sysfs sysfs "${rootfs_dir}/sys"
mount -t proc proc "${rootfs_dir}/proc"
mkdir -p ${rootfs_dir}/dev/pts
mount -t devpts devpts "${rootfs_dir}/dev/pts"

chroot "${rootfs_dir}" /bin/bash -e chroot.sh
rm ${rootfs_dir}/chroot.sh
rm ${rootfs_dir}/requirements.txt
sync

umount -fl "${rootfs_dir}/dev/pts"
umount -fl "${rootfs_dir}/proc"
umount -fl "${rootfs_dir}/sys"
umount -fl "${rootfs_dir}/run"

rm ${rootfs_dir}/usr/bin/qemu-arm-static

echo "Log: (debootstrap) compressing rootfs, please wait..."
tar -C ${rootfs_dir} -czf ${output_dir}/rootfs.tar.gz .
echo "Log: (debootstrap) Complete"
