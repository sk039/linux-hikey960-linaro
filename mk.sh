#!/usr/bin/env bash
export ARCH=arm64
export CROSS_COMPILE=/opt/gcc-linaro-6.4.1-2018.05-x86_64_aarch64-elf/bin/aarch64-elf-
export TOPDIR=$(pwd)
export KERN_REL=$(make kernelrelease)

make all 
TMPDIR=`mktemp -d`

cd $TMPDIR
cat $TOPDIR/initrd.img | gunzip | cpio -idum
rm -rf $TMPDIR/lib/modules/*

cd $TOPDIR
make modules_install INSTALL_MOD_PATH=$TMPDIR

cd $TMPDIR
find . | cpio -o -R root:root -H newc | gzip > $TOPDIR/initrd-${KERN_REL}.img

cd $TOPDIR
mkbootimg --kernel arch/arm64/boot/Image.gz-dtb --ramdisk initrd-${KERN_REL}.img --cmdline "root=/dev/mmcblk0p1 rw rootwait console=ttyAMA6,115200 earlycon=pl011,0xfff32000" -o boot.img

#fastboot boot boot.img
