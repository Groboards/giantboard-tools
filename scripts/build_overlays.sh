#!/bin/bash                                                                                                                              
# restart script with root privileges if not already
[ "$UID" -eq 0 ] || exec sudo "$0" "$@" ]

patch_dir="$(pwd)/patches/overlays"
output_dir="$(pwd)/output"
overlays_dir="${output_dir}/overlays"

mkdir -p "${overlays_dir}"

# overlays array
declare -a overlays=("GB-24LCD-FEATHERWING"
					 "GB-ETHERNET-FEATHERWING"
					 "GB-I2C0"
					 "GB-I2S0"
					 "GB-I2S0-NO-MCK"
					 "GB-I2S0-NO-MCK-NO-DI"
					 "GB-PWM1"
					 "GB-PWM1-3"
					 "GB-PWM2"
					 "GB-SPI0-ENC28J60"
					 "GB-SPI0-SPIDEV-CS-PWML1"
					 "GB-SPI0-SPIDEV-NO-CS"
					 "GB-WIFI-FEATHERWING"
					 "GB-UART2-FLX4-AD2-AD3")

# Install all the libs listed in the blinka_libs array
#dtc -@ -I dts -O dtb -o ${overlays_dir}/"$i".dtbo ${patch_dir}/"$i".dts

for i in "${overlays[@]}"
do
	cpp -Iinclude -E -P -x assembler-with-cpp ${patch_dir}/"$i".dts | dtc -@ -I dts -O dtb -o ${overlays_dir}/"$i".dtbo
done

echo "done building.."
