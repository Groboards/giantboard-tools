#!/bin/sh

echo "exporting compilering.."
export CC=`pwd`/tools/gcc-linaro-6.4.1-2018.05-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
echo "Downloading the latest at91bootstrcap"
git clone https://github.com/linux4sam/at91bootstrap
cd at91bootstrap/
git checkout v3.8.10 -b tmp
echo "building at91bootstrap"
make ARCH=arm CROSS_COMPILE=${CC} distclean
make ARCH=arm CROSS_COMPILE=${CC} sama5d27_som1_eksd1_uboot_defconfig
make ARCH=arm CROSS_COMPILE=${CC}
echo "finished building at91bootstrap"
