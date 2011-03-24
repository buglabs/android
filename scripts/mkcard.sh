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

if [ "$(id -u)" != "0" ]; then
	echo "This script must be run as root."
	exit 1
fi

DRIVE=$1
TARBALL=$2

if [ ! -f ${DRIVE} ]; then
	echo "Drive ${DRIVE} does not exist."
	exit 1
fi

# Remove directories that may be hanging around from prevoius partial or erronous run.
if [ -d /tmp/mp1 ]; then
  rm -Rf /tmp/mp1
fi

if [ -d /tmp/mkcard ]; then
  rm -Rf /tmp/mkcard 
fi

# Create temporary mount point
mkdir /tmp/mp1

/bin/umount ${DRIVE}1 > /dev/null 2>&1
/bin/umount ${DRIVE}p1 > /dev/null 2>&1
dd if=/dev/zero of=${DRIVE} bs=1024 count=1024
echo "Partitioning Disk $DEVNAME"
echo "d
n
p
1


a
1
w
" | fdisk ${DRIVE} > /dev/null 2>&1
/bin/umount ${DRIVE}1 > /dev/null 2>&1
/bin/umount ${DRIVE}p1 > /dev/null 2>&1

sleep 1

if [ -b ${DRIVE}1 ]; then
	umount ${DRIVE}1 > /dev/null 2>&1
	mke2fs -j -L "root" ${DRIVE}1
	ROOT_PARTITION=${DRIVE}1
else
	if [ -b ${DRIVE}p1 ]; then
		umount ${DRIVE}p1 > /dev/null 2>&1
		mke2fs -j -L "root" ${DRIVE}p1
		ROOT_PARTITION=${DRIVE}p1
	else
		echo "Cant find rootfs partition in /dev"
	fi
fi
sleep 1

set +e
mkdir /tmp/mkcard
echo "Extracting contents of image tarball to $ROOT_PARITION"
mount $ROOT_PARTITION /tmp/mp1

tar xfz $TARBALL -C /tmp/mkcard

echo "Writing contents to sd card..."
mkdir /tmp/mp1/boot
cp /tmp/mkcard/uImage /tmp/mp1/boot/
tar xf /tmp/mkcard/rootfs.tar -C /tmp/mp1

sync
umount $ROOT_PARTITION
sleep 1
rmdir /tmp/mp1
rm -Rf /tmp/mkcard
echo "Completed succesfully, sd card ${DRIVE} ready to be booted."