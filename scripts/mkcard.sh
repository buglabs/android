#! /bin/sh
# mkcard.sh v0.5
# (c) Copyright 2009 Graeme Gregory <dp@xora.org.uk>
# Licensed under terms of GPLv2
#
# Parts of the procudure base on the work of Denys Dmytriyenko
# http://wiki.omap.com/index.php/MMC_Boot_Format
# 
# Extended by Ken Gilmer <kgilmer@buglabs.net> for use with Android on BUG 2.0 project.

export LC_ALL=C

if [ $# -ne 2 ]; then
	echo "Usage: $0 <disk device> <image tarball>"
	echo "Ex: $0 /dev/mmcxxx dist-jenkins-android-froyo-integration-28.tar.gz"
	exit 1;
fi

DRIVE=$1
TARBALL=$2

mkdir /tmp/mp1
mkdir /tmp/mp2

dd if=/dev/zero of=$DRIVE bs=1024 count=1024

SIZE=`fdisk -l $DRIVE | grep Disk | grep bytes | awk '{print $5}'`

echo DISK SIZE - $SIZE bytes

CYLINDERS=`echo $SIZE/255/63/512 | bc`

echo CYLINDERS - $CYLINDERS

{
echo ,9,0x0C,*
echo ,,,-
} | sfdisk -D -H 255 -S 63 -C $CYLINDERS $DRIVE

sleep 1

if [ -b ${DRIVE}1 ]; then
	umount ${DRIVE}1
	mkfs.vfat -F 32 -n "boot" ${DRIVE}1
	BOOT_PARTITION=${DRIVE}1
else
	if [ -b ${DRIVE}p1 ]; then
		umount ${DRIVE}p1
		mkfs.vfat -F 32 -n "boot" ${DRIVE}p1
		BOOT_PARTITION=${DRIVE}p1
	else
		echo "Cant find boot partition in /dev"
	fi
fi

if [ -b ${DRIVE}2 ]; then
	umount ${DRIVE}2
	mke2fs -j -L "root" ${DRIVE}2
	ROOT_PARTITION=${DRIVE}2
else
	if [ -b ${DRIVE}p2 ]; then
		umount ${DRIVE}p2
		mke2fs -j -L "root" ${DRIVE}p2
		ROOT_PARTITION=${DRIVE}p2
	else
		echo "Cant find rootfs partition in /dev"
	fi
fi
sleep 1

set +e
mkdir /tmp/mkcard
echo "Extracting contents of image tarball..."
mount $BOOT_PARTITION /tmp/mp1
mount $ROOT_PARTITION /tmp/mp2

tar xfz $TARBALL -C /tmp/mkcard

echo "Writing contents to sd card..."
cp /tmp/mkcard/uImage /tmp/mp1/
tar xf /tmp/mkcard/rootfs.tar -C /tmp/mp2 

sync
umount $BOOT_PARTITION
umount $ROOT_PARTITION
sleep 1
rmdir /tmp/mp1
rmdir /tmp/mp2
rm -Rf /tmp/mkcard
echo "Completed succesfully, sd card is ready to be booted."