#!/bin/bash

# Build variables
patch_dir="$(pwd)/patches/u-boot"
output_dir="$(pwd)/output"
build_dir="${output_dir}/build"
uboot_bin="${output_dir}/u-boot"
uboot_dir="${build_dir}/u-boot"

# specify compiler 
CC=`pwd`/tools/gcc-linaro-6.4.1-2018.05-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-

echo "making output dir."
# Make the u-boot output dir
mkdir -p "${uboot_bin}"

# clone u-boot
git -C ${build_dir} clone https://github.com/u-boot/u-boot

echo "patching.."

cp patches/u-boot/at91-sama5d27_giantboard.dts ${uboot_dir}/arch/arm/dts/
cp patches/u-boot/sama5d27_giantboard.dtsi ${uboot_dir}/arch/arm/dts/
cp patches/u-boot/sama5d27_giantboard_mmc_defconfig ${uboot_dir}/configs/

patch -d ${uboot_dir} -p1 < patches/u-boot/giantboard-fixes.patch 

echo "patches complete.."
echo "starting u-boot build.."
make -C ${uboot_dir} ARCH=arm CROSS_COMPILE=${CC} distclean
make -C ${uboot_dir} ARCH=arm CROSS_COMPILE=${CC} sama5d27_giantboard_mmc_defconfig
make -C ${uboot_dir} ARCH=arm CROSS_COMPILE=${CC}

cp -v ${uboot_dir}/u-boot.bin ${uboot_bin}

echo "finished building u-boot"
