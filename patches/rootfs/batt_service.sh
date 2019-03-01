#!/bin/bash
boot_arg=giantboard.disable_charging

if grep -iq "${boot_arg}=[a-zA-Z0-9]" /proc/cmdline
then
    sudo i2cset -f -y 1 0x5b 0x71 129
    echo "Battery charging disabled"
else
    sudo i2cset -f -y 1 0x5b 0x71 0x00
    echo "Battery charging enabled"
fi
