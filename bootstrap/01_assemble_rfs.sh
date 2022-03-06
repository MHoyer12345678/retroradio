#!/bin/bash

DEBIAN_DISTRIBUTION=buster
DEBIAN_MIRROR=http://ftp.de.debian.org/debian
DEBIAN_COMPONENTS=main,non-free

ARCHITECTURE=armel

BSP_DIR=./rasp-bsp
RFS_DIR=/var/nfs/rfs

PACKAGES=systemd,bash,udev,openssh-server,ifupdown,kmod,net-tools,firmware-brcm80211,isc-dhcp-client,psmisc,wpasupplicant

if [ $UID -ne 0 ]; then
    echo "Please run as root ..."
    exit 1
fi

if [ ! -d $BSP_DIR ]; then
    echo "No clone from raspberry firmware git found here: $BSP_DIR"
    echo "Please download one from https://github.com/raspberrypi/firmware and place it here."
    exit 1
fi

if [ ! -d $RFS_DIR ]; then
    echo "Please create a writable directory for the generated RFS: $RFS_DIR"
    exit 1
fi

echo "---------------- Creating minimal debian RFS for bootstrapping -------------------------------"
echo "Debian distro: $DEBIAN_DISTRIBUTION"
echo "Debian mirror: $DEBIAN_MIRROR"
echo "distro components: $DEBIAN_COMPONENTS" 
echo "Architecture: $ARCHITECTURE"
echo "Packages: $PACKAGES"
echo "Firmware directory: $BSP_DIR"
echo "RFS directory: $RFS_DIR"
echo "----------------------------------------------------------------------------------------------"
echo
echo "Starting in 5 secs ..."

sleep 5

#create rfs
echo "Removing everything from RFS directory ..."
rm -r $RFS_DIR/*
echo "Creating RFS ..."
qemu-debootstrap --variant minbase --components $DEBIAN_COMPONENTS --include=$PACKAGES --arch=$ARCHITECTURE $DEBIAN_DISTRIBUTION $RFS_DIR $DEBIAN_MIRROR || exit 1

#installing kernel modules
echo "Installing kernel modules ..."
mkdir $RFS_DIR/lib/modules || exit 1
cp -r $BSP_DIR/firmware-master/modules/*-v7+ $RFS_DIR/lib/modules/ || exit 1
cp -r $BSP_DIR/firmware-master/modules/*+ $RFS_DIR/lib/modules/ || exit 1


echo "Doing some modifications in the RFS ..."
#installing txt file missing for broadcom wifi chip
cp files/brcmfmac43430-sdio.txt $RFS_DIR/lib/firmware/brcm/ || exit 1

#create symlink to systemd
ln -s /lib/systemd/systemd $RFS_DIR/sbin/init || exit 1

#remove root password
sed 's/root:\*/root:/' $RFS_DIR/etc/shadow > $RFS_DIR/etc/shadow_x || exit 1
mv $RFS_DIR/etc/shadow_x $RFS_DIR/etc/shadow || exit 1

#add user joe
mkdir $RFS_DIR/home/joe || exit 1
chown 1000:1000  $RFS_DIR/home/joe || exit 1
chmod 755 $RFS_DIR/home/joe || exit 1
echo "joe:x:1000:1000::/home/joe:/bin/bash" >> $RFS_DIR/etc/passwd || exit 1

#set std password from joe
echo "joe::17994:0:99999:7:::" >> $RFS_DIR/etc/shadow || exit 1

#install public key file for ssh
mkdir $RFS_DIR/home/joe/.ssh
cp files/id_rsa.pub $RFS_DIR/home/joe/.ssh/authorized_keys

#installing some configuration files
cp files/interfaces $RFS_DIR/etc/network/ || exit 1

echo "Created RFS successfully in folder: $RFS_DIR"
