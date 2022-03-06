#!/bin/bash

BSP_DIR=./rasp-bsp/firmware-master

if [ $# -eq 0 ]; then
    echo "mount point missing ..."
    exit 1
fi

if [ ! -d $1 ]; then
    echo "$1 is not a mount point"
    exit 1
fi

echo "Going to empty boot partition on sd card in 5 secs"

sleep 5

echo "Emptying boot partition on sd card"

rm -r $1/*

echo "Copying kernel and device tree stuff to boot partition"
cp -r $BSP_DIR/boot/* $1/

echo "Installing cmdline.txt [version: boot from sd card]"
cp files/cmdline.txt.sd $1/cmdline.txt

echo "Installing config.txt"
cp files/config.txt	$1/

