#!/bin/sh
clear
echo "Build Options:"
echo "1: Setup Build Environment.(Run on first setup.)"
echo "2: Build at91bootstrap"
echo "3: Build u-boot"
echo "4: Build kernel"
echo "5: Build debian rootfs"
echo "6: Make bootable device image"
	
setup_env () {
	chmod +x scripts/setup_env.sh
	chmod +x scripts/build_at91bootstrap.sh
	chmod +x scripts/build_u-boot.sh
	chmod +x scripts/build_kernel.sh
	chmod +x scripts/build_debian-rootfs.sh
	chmod +x scripts/make-image.sh
	sh scripts/setup_env.sh
}

build_at91bootstrap () {
	sh scripts/build_at91bootstrap.sh
}

build_uboot () {
	sh scripts/build_u-boot.sh
}

build_kernel () {
	sh scripts/build_kernel.sh
}

build_debianrootfs () {
	sh scripts/build_debian-rootfs.sh
}

make_image () {
	sh scripts/make-image.sh
}

read -p "Enter selection [1-6] > " option

case $option in
	1)
		clear
		echo "Setting up build enviroment.."
		setup_env
		;;
	2)
		clear
		echo "Setting up at91bootstrap.."
		build_at91bootstrap
		;;
	3)
		clear
		echo "Preparing to build u-boot.."
		build_uboot
		;;
	4)
		clear
		echo "Preparing to build kernel.."
		build_kernel
		;;
	5) 
		clear
		echo "Preparing to build rootfs.."
		build_debianrootfs
		;;
	6) 
		clear
		echo "Preparing to make image.."
		make_image
		;;
	*)
		echo "No Option Selected, exiting.."
		;;
esac
