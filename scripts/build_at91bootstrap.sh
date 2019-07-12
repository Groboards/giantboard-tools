#!/bin/bash

# Build variables
output_dir="$(pwd)/output"
build_dir="${output_dir}/build"
patch_dir="$(pwd)/patches/at91bootstrap"
at91boot_bin="${output_dir}/at91bootstrap"
at91boot_dir="${build_dir}/at91bootstrap"

# specify compiler
CC=`pwd`/tools/gcc-linaro-6.4.1-2018.05-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-

echo "making output dir."
# Make the at91bootstrap output dir
mkdir -p "${at91boot_bin}"

echo "Downloading the latest at91bootstrap"
git -C ${build_dir} clone https://github.com/linux4sam/at91bootstrap
git -C ${at91boot_dir} checkout v3.8.13 -b tmp
echo "building at91bootstrap"

# copy config
cp ${patch_dir}/sama5d27_giantboard_sd1_uboot_defconfig ${at91boot_dir}/board/sama5d27_som1_ek/

make -C ${at91boot_dir} ARCH=arm CROSS_COMPILE=${CC} distclean
make -C ${at91boot_dir} ARCH=arm CROSS_COMPILE=${CC} sama5d27_giantboard_sd1_uboot_defconfig
make -C ${at91boot_dir} ARCH=arm CROSS_COMPILE=${CC}

# copy the built bin to the output
cp -v ${at91boot_dir}/binaries/sama5d27_som1_ek-sdcardboot-uboot-3.8.13.bin ${at91boot_bin}/BOOT.BIN

echo "finished building at91bootstrap"
