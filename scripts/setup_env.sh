#!/bin/sh

echo "Getting compiler.."
wget -c https://releases.linaro.org/components/toolchain/binaries/6.4-2018.05/arm-linux-gnueabihf/gcc-linaro-6.4.1-2018.05-x86_64_arm-linux-gnueabihf.tar.xz
echo "extracting compiler.."
mkdir tools
tar xf gcc-linaro-6.4.1-2018.05-x86_64_arm-linux-gnueabihf.tar.xz -C tools
rm gcc-linaro-6.4.1-2018.05-x86_64_arm-linux-gnueabihf.tar.xz

echo "Installing tools.."
sudo apt install build-essential bc bison flex libncurses-dev libssl-dev debootstrap qemu-user-static -y
echo "done.."
