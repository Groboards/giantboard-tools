#!/bin/bash
echo "$(pwd)/tools"
if [ ! -d "$(pwd)/tools" ]; then
	echo "Getting compiler.."
	wget -c https://releases.linaro.org/components/toolchain/binaries/latest-7/arm-linux-gnueabihf/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz
	echo "extracting compiler.."
	mkdir tools
	tar xf gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz -C tools
	rm gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz
fi

echo "Installing tools.."
release=$(awk -F= '$1=="ID" { print $2 ;}' /etc/os-release)
echo "${release}"
case "${release}" in
debian|ubuntu)
	sudo apt install -y \
		build-essential \
		bc bison flex \
		libncurses-dev \
		libssl-dev debootstrap \
		qemu-user-static \
		device-tree-compiler \
		dosfstools
	;;
fedora)
	sudo dnf install -y \
		@development-tools \
		bison flex \
		ncurses-devel \
		openssl-devel \
		debootstrap \
		qemu-user-static \
		dtc \
		dosfstools
	;;
esac
echo "done.."
