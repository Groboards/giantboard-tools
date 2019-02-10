#!/bin/bash

export CC=`pwd`/tools/gcc-linaro-6.4.1-2018.05-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-
echo "Downloading u-boot"
git clone https://github.com/u-boot/u-boot
cd u-boot/
git checkout v2019.01 -b tmp
echo "getting patches"
wget -c https://github.com/eewiki/u-boot-patches/raw/master/v2019.01/0001-ARM-at91-Convert-SPL_GENERATE_ATMEL_PMECC_HEADER-to-.patch
echo "patching.."
cp ../patches/u-boot/at91-sama5d27_giantboard.dts arch/arm/dts/
cp ../patches/u-boot/sama5d27_giantboard.dtsi arch/arm/dts/
cp ../patches/u-boot/sama5d27_giantboard_mmc_defconfig configs/

patch -p1 < 0001-ARM-at91-Convert-SPL_GENERATE_ATMEL_PMECC_HEADER-to-.patch
patch -p1 < ../patches/u-boot/giantboard-fixes.patch

echo "patches complete.."
echo "starting u-boot build.."
make ARCH=arm CROSS_COMPILE=${CC} distclean
make ARCH=arm CROSS_COMPILE=${CC} sama5d27_giantboard_mmc_defconfig
make ARCH=arm CROSS_COMPILE=${CC}
echo "finished building u-boot"
