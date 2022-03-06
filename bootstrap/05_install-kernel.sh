#!/bin/bash

if [ $UID -ne 0 ]; then
    echo "Please run as root ..."
    exit 1
fi

echo "Installing kernel ..."

echo "Setting time read from time.txt"

timeToSet=$(cat time.txt)
date -s "${timeToSet}"

echo "Unpacking kernel modules ..."
tar -C /tmp -xf kernel/kpkg/modules.tgz
cp -r /tmp/lib/modules/* /lib/modules/
echo "Mounting boot partition"
mount /dev/mmcblk0p1 /boot
echo "Copying dtbs to boot partition"
cp -r kernel/kpkg/dtbs/* /boot/
echo "Copying kernel image to boot partition"
cp -r kernel/kpkg/image/* /boot/

echo "Done"
umount /boot

echo "Reboot before installing any additional stage ..."

