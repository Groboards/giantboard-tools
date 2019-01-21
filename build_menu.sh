#!/bin/sh
clear
echo "Build Options:"
echo "1: Setup Build Environment.(Run on first setup.)"
echo "2: Build at91bootstrap"
echo "3: Build u-boot"
echo "4: Build kernel"
echo "5: Rebuild at91bootstrap"
echo "6: Rebuild u-boot"
echo "7: Rebuild kernel"
	
setup_env () {
	chmod +x scripts/setup_env.sh
	chmod +x scripts/build_at91bootstrap.sh
	chmod +x scripts/build_u-boot.sh
	chmod +x scripts/build_kernel.sh
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

read -p "Enter selection [1-7] > " option

case $option in
	1)
		echo "Setting up build enviroment.."
		setup_env
		;;
	2)
		echo "Setting up at91bootstrap.."
		build_at91bootstrap
		;;
	3)
		echo "Preparing to build u-boot.."
		build_uboot
		;;
	4)
		echo "Preparing to build kernel.."
		build_kernel
		;;
	*)
		echo "No Option Selected, exiting.."
		;;
esac
