#!/bin/bash

output_dir="$(pwd)/output"
build_dir="${output_dir}/build"

clear
echo "Build Options:"
echo "1: Setup Build Environment.(Run on first setup.)"
echo "2: Build at91bootstrap"
echo "3: Build u-boot"
echo "4: Build kernel/clean"
echo "5: Rebuild kernel"
echo "6: Build debian rootfs"
echo "7: Chroot into rootfs"
echo "8: Build device overlays"
echo "9: Make bootable device image"
	
setup_env () {
	chmod +x scripts/setup_env.sh
	chmod +x scripts/build_at91bootstrap.sh
	chmod +x scripts/build_u-boot.sh
	chmod +x scripts/build_kernel.sh
	chmod +x scripts/build_debian-rootfs.sh
	chmod +x scripts/build_overlays.sh
	chmod +x scripts/chroot-interactive.sh
	chmod +x scripts/make-image.sh
	mkdir -p "${build_dir}"
	scripts/setup_env.sh
}

build_at91bootstrap () {
	scripts/build_at91bootstrap.sh
}

build_uboot () {
	scripts/build_u-boot.sh
}

build_kernel () {
	scripts/build_kernel.sh clean
}

rebuild_kernel () {
	scripts/build_kernel.sh
}

build_debianrootfs () {
	scripts/build_debian-rootfs.sh
}

build_overlays () {
	scripts/build_overlays.sh
}

chroot_interactive () {
	scripts/chroot-interactive.sh
}

make_image () {
	scripts/make-image.sh
}

read -p "Enter selection [1-7] > " option

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
		echo "Preparing to rebuild kernel.."
		rebuild_kernel
		;;
	6) 
		clear
		echo "Preparing to build rootfs.."
		build_debianrootfs
		;;
	7)
		clear
		echo "Preparing to chroot.."
		chroot_interactive
		;;
	8) 
		clear
		echo "Building overlays.."
		build_overlays
		;;
	9) 
		clear
		echo "Preparing to make image.."
		make_image
		;;
	*)
		echo "No Option Selected, exiting.."
		;;
esac
