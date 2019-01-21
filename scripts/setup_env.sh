#!/bin/sh

echo "Getting compiler.."
wget -c https://releases.linaro.org/components/toolchain/binaries/6.4-2018.05/arm-linux-gnueabihf/gcc-linaro-6.4.1-2018.05-x86_64_arm-linux-gnueabihf.tar.xz
echo "extracting compiler.."
tar xf gcc-linaro-6.4.1-2018.05-x86_64_arm-linux-gnueabihf.tar.xz -C tools
rm gcc-linaro-6.4.1-2018.05-x86_64_arm-linux-gnueabihf.tar.xz
echo "done.."
