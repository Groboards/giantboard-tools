#!/bin/bash -e
CC="$(pwd)/tools/gcc-linaro-6.4.1-2018.05-x86_64_arm-linux-gnueabihf/bin/arm-linux-gnueabihf-"

output_dir="$(pwd)/output"
build_dir="${output_dir}/build"
linux_dir="${build_dir}/linux"
modules_dir="${output_dir}/modules"
release="v5.0-rc2"

cross_make="make -C ${linux_dir} ARCH=arm CROSS_COMPILE=${CC}"

patches=""

mkdir -p ${build_dir}

if [ ! -d "${linux_dir}" ]; then
	echo "downloading lastest kernel from github.."
	git -C ${build_dir} clone https://github.com/torvalds/linux.git
	# git -C ${build_dir} clone --depth=1 --branch ${release} https://github.com/torvalds/linux.git
fi

if [ ! -f "${output_dir}/.patches_applied" ]; then
	echo "applying patches.."
	cp patches/kernel/at91-sama5d27_giantboard.dtsi ${linux_dir}/arch/arm/boot/dts/
	cp patches/kernel/at91-sama5d27_giantboard.dts ${linux_dir}/arch/arm/boot/dts/
	sed -i '50i at91-sama5d27_giantboard.dtb \\' ${linux_dir}/arch/arm/boot/dts/Makefile
	touch "${output_dir}/.patches_applied"
	
fi

echo "preparing kernel.."
echo "cross_make: ${cross_make}"
${cross_make} distclean
if [ ! -f "${linux_dir}/.config" ]; then
	${cross_make} sama5_defconfig
fi
${cross_make} menuconfig
built_version="$(${cross_make} --no-print-directory -s kernelversion 2>/dev/null)"
built_release="$(${cross_make} --no-print-directory -s kernelrelease 2>/dev/null)"
echo "version: $version"
echo "release: $release"
${cross_make}
${cross_make} dtbs
${cross_make} modules
${cross_make} modules_install INSTALL_MOD_PATH="${modules_dir}"
echo "done building.."
echo "preparing tarball"
tar -czf "${output_dir}/modules-${built_version}.tar.gz" -C "${modules_dir}" .
ls -hal "${output_dir}/modules-${built_version}.tar.gz"
echo "complete!"
