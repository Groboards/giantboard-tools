#!/bin/bash                                                                                                                                 
# restart script with root privileges if not already
[ "$UID" -eq 0 ] || exec sudo "$0" "$@" ]

output_dir="$(pwd)/output"
patch_dir="$(pwd)/patches/rootfs"
rootfs_dir="${output_dir}/rootfs"
min_rootfs_dir="${output_dir}/min_rootfs"


cp /usr/bin/qemu-arm-static ${rootfs_dir}/usr/bin/

mount -t tmpfs run "${rootfs_dir}/run"

mount -t sysfs sysfs "${rootfs_dir}/sys"
mount -t proc proc "${rootfs_dir}/proc"
mkdir -p ${rootfs_dir}/dev/pts
mount -t devpts devpts "${rootfs_dir}/dev/pts"

chroot "${rootfs_dir}" /bin/bash
sync

umount -fl "${rootfs_dir}/dev/pts"
umount -fl "${rootfs_dir}/proc"
umount -fl "${rootfs_dir}/sys"
umount -fl "${rootfs_dir}/run"

rm ${rootfs_dir}/usr/bin/qemu-arm-static
