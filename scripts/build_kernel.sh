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

# since we call these programs often, make calling them simpler
cross_make="make -C ${linux_dir} ARCH=arm CROSS_COMPILE=${CC}"

# TODO: make these user-specifiable defaults
patches=""
release="${release:-v5.3}"

echo "Building kernel release: ${release}"
mkdir -p "${build_dir}"
mkdir -p "${images_dir}"

# function to process script arguments and set appropriate variables
process_options()
{
	#
	# supported options:
	#   -p, --patches
	#     Specify patch sets to apply to the kernel. Patch sets exist in
	#     the directory patches/kernel/[patchset name]/
	#
	#     Each directory can contain a set of .patch files that will be
	#     applied. They may also contain a '.external-patches' file, which
	#     can be used for downloading them and applying them. The
	#     '.external-patches' file is considered a development feature and
	#     will be ignored by git.
	#
        local options=$(getopt -o p: --long patches: -- "$@")
        [ $? -eq 0 ] || { 
            echo "Incorrect options provided"
            exit 1
        }   
                                                                                                                                                                            
        eval set -- "$options"
        while true; do
                case "$1" in
                        -p|--patches)
                                patches="$2"
				shift
                                ;;  
                        --) 
                                shift
                                break
                                ;;  
                esac
                shift
        done
}
process_options "$@"

if [ ! -d "${linux_dir}" ]; then
	echo "Getting ${release} kernel from https://github.com/torvalds/linux.."
	# TODO: allow cloning of a single depth/release
	git -C ${build_dir} clone https://github.com/torvalds/linux.git
    git -C ${linux_dir} checkout ${release} -b tmp
	#git -C ${build_dir} clone --depth=1 --branch ${release} https://github.com/torvalds/linux.git
fi

# check if patches have already been applied, if so, get list of patchsets
if [ -f "${output_dir}/.patches_applied" ]; then
	patches_applied=$(cat "${output_dir}/.patches_applied")
	echo "${patches_applied}"
else
	echo "No patches"
	patches_applied="none"
fi

# check if patches_applied is empty or not equal to our current list of patches
if [ -z "${patches_applied}" ] || [ "${patches_applied}" != "${patches[@]}" ]; then
	# if we are applying different patchsets, we need a clean base
	# reset the kernel to the specified release
	git -C ${linux_dir} checkout ${release}
	# These patches are currently applied always applied.
	# TODO: move these into patch files and add them as the "default" patchset.
	# This will allow someone to turn off the patches easily once they get mainlined.
	echo "applying patches.."
	cp patches/kernel/at91-sama5d27_giantboard.dtsi ${linux_dir}/arch/arm/boot/dts/
	cp patches/kernel/at91-sama5d27_giantboard.dts ${linux_dir}/arch/arm/boot/dts/
	cp patches/kernel/giantboard_defconfig ${linux_dir}/arch/arm/configs
	sed -i '50i at91-sama5d27_giantboard.dtb \\' ${linux_dir}/arch/arm/boot/dts/Makefile

	# convert patches variable from comma-separated list of patches to an array
	patches=(${patches//,/ })

	# loop through specified patchsets
        for patchset in "${patches[@]}"; do
		# if patchset directory exists, we can apply them
		current_patch_dir="${patch_dir}/${patchset}"
		if [ -d "${current_patch_dir}" ]; then
		        echo "Applying patchset ${patchset}"

			# first, check for existence of '.external-patches' and apply that
			if [ -f "${current_patch_dir}/.external-patches" ]; then
				#
				echo "Using ${current_patch_dir}/.external-patches"
				while IFS='' read -r patch_url; do
					if [ ! -z "${patch_url}" ]; then
						curl "${patch_url}" | git -C "${linux_dir}" am
					fi
				done < "${current_patch_dir}/.external-patches"
			else
				# if '.external-patches' does not exist, apply all .patch files
				for patchfile in "${current_patch_dir}"/*.patch; do
					echo "Patchfile: ${patchfile}"
					git -C "${linux_dir}" am < "${patchfile}"
				done
			fi
		else
			# patchset directory nonexistent. Error out
			echo "Error: No patchset found: ${patchset}"
			exit 1
		fi
        done
        echo "Patches to apply: ${patches[@]}"

	echo "${patches[@]}" > "${output_dir}/.patches_applied"
	
fi

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
${cross_make} distclean

# only call with defconfig if a config file doesn't exist already
if [ ! -f "${linux_dir}/.config" ]; then
	${cross_make} giantboard_defconfig
fi
${cross_make} menuconfig

# here we are grabbing the kernel version and release information from kbuild
built_version="$(${cross_make} --no-print-directory -s kernelversion 2>/dev/null)"
built_release="$(${cross_make} --no-print-directory -s kernelrelease 2>/dev/null)"

cores=$(( $(nproc) * 2 ))
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
