#!/bin/bash                                                                                                                              
# restart script with root privileges if not already
[ "$UID" -eq 0 ] || exec sudo "$0" "$@" ]

patch_dir="$(pwd)/patches/overlays"
output_dir="$(pwd)/output"
overlays_dir="${output_dir}/overlays"

mkdir -p "${overlays_dir}"

# overlays array
declare -a overlays=("GB-22LCD-FEATHERWING"
					"GB-ETHERNET-FEATHERWING"
					"GB-SPI0-ENC28J60")

# Install all the libs listed in the blinka_libs array
for i in "${overlays[@]}"
do
	dtc -@ -I dts -O dtb -o ${overlays_dir}/"$i".dtbo ${patch_dir}/"$i".dts
done

echo "done building.."
