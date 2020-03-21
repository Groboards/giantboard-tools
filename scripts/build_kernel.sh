#!/bin/bash -e
CC="$(pwd)/tools/gcc-linaro-6.4.1-2018.05-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-"

# directory variables for easier maintainability
output_dir="$(pwd)/output"
patch_dir="$(pwd)/patches/kernel"
modules_dir="${output_dir}/modules"
headers_dir="${output_dir}/headers"
build_dir="${output_dir}/build"
linux_dir="${build_dir}/linux"
images_dir="${output_dir}/images"

# core count for compiling with -j
cores=$(( $(nproc) * 2 ))

# since we call these programs often, make calling them simpler
cross_make="make -C ${linux_dir} ARCH=arm CROSS_COMPILE=${CC}"


patches=""
release="${release:-v5.0}"


echo "Building kernel release: ${release}"
mkdir -p "${build_dir}"
mkdir -p "${images_dir}"

# check for the linux directory
if [ ! -d "${linux_dir}" ]; then
	echo "Getting ${release} kernel from https://github.com/torvalds/linux.."
	git -C ${build_dir} clone https://github.com/torvalds/linux.git
    git -C ${linux_dir} checkout ${release} -b tmp
fi

# always do a checkout to see if chosen kernel version has changed
#git -C ${linux_dir} checkout ${release} -b tmp

export KBUILD_BUILD_USER="giantboard"
export KBUILD_BUILD_HOST="giantboard"

echo "applying patches.."
cp patches/kernel/at91-sama5d27_giantboard.dtsi ${linux_dir}/arch/arm/boot/dts/
cp patches/kernel/at91-sama5d27_giantboard.dts ${linux_dir}/arch/arm/boot/dts/
cp patches/kernel/giantboard_defconfig ${linux_dir}/arch/arm/configs
sed -i '50i at91-sama5d27_giantboard.dtb \\' ${linux_dir}/arch/arm/boot/dts/Makefile


# Add wifi driver to source tree
rm -rf ${linux_dir}/drivers/staging/wilc1000
mkdir -p ${linux_dir}/drivers/staging/wilc1000
git clone https://github.com/linux4wilc/driver.git
mv driver/wilc/* ${linux_dir}/drivers/staging/wilc1000/
patch -d ${linux_dir} -p1 < patches/kernel/Kconfig.patch
patch -d ${linux_dir} -p1 < patches/kernel/Makefile.patch  
rm -rf driver


echo "preparing kernel.."
echo "cross_make: ${cross_make}"
#

if [ $1 == "clean" ]; then
	${cross_make} distclean
fi

# only call with defconfig if a config file doesn't exist already
if [ ! -f "${linux_dir}/.config" ]; then
	${cross_make} giantboard_defconfig
fi

${cross_make} menuconfig

# here we are grabbing the kernel version and release information from kbuild
built_version="$(${cross_make} --no-print-directory -s kernelversion 2>/dev/null)"
built_release="$(${cross_make} --no-print-directory -s kernelrelease 2>/dev/null)"

# build the dtb's, modules, and headers
${cross_make} -j"${cores}"
DTC_FLAGS="-@" ${cross_make} dtbs -j"${cores}"
${cross_make} modules -j"${cores}"
${cross_make} modules_install INSTALL_MOD_PATH="${modules_dir}"
${cross_make} headers_install INSTALL_HDR_PATH="${headers_dir}"


echo "done building.."
echo "preparing tarball"
tar -czf "${images_dir}/modules-${built_version}.tar.gz" -C "${modules_dir}" .
tar -czf "${images_dir}/headers-${built_version}.tar.gz" -C "${headers_dir}" .
ls -hal "${images_dir}/modules-${built_version}.tar.gz"
echo "copying kernel files"


# copy the kernel zImage and giantboard dtb to our images directory
cp ${linux_dir}/arch/arm/boot/zImage ${images_dir}/
cp ${linux_dir}/arch/arm/boot/dts/at91-sama5d27_giantboard.dtb ${images_dir}/
echo "complete!"
