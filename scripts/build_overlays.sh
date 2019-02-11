#!/bin/bash                                                                                                                                 

patch_dir="$(pwd)/patches/overlays"
output_dir="$(pwd)/output"
firmware_dir="${output_dir}/firmware"

mkdir -p "${firmware_dir}"

# overlays array
declare -a overlays=("GB-22LCD-FEATHERWING"
					"GB-ETHERNET-FEATHERWING"
					"GB-SPI0-ENC28J60")

# Install all the libs listed in the blinka_libs array
for i in "${overlays[@]}"
do
	dtc -@ -I dts -O dtb -o ${firmware_dir}/"$i".dtbo ${patch_dir}/"$i".dts
done

echo "done building.."
