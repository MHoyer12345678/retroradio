#!/bin/bash

RFS_DIR=/var/nfs/rfs

if [ $UID -ne 0 ]; then
    echo "Please run as root ..."
    exit 1
fi

if [ $# -eq 0 ]; then
    echo "mount point missing ..."
    exit 1
fi

if [ ! -d $1 ]; then
    echo "$1 is not a mount point"
    exit 1
fi

echo "Going to empty partition on sd card in 5 secs"
sleep 5

echo "Emptying partition on sd card"
rm -r $1/*

echo "Copying RFS from $RFS_DIR"
tar -c -C $RFS_DIR . | tar -x -C $1/ 

sync
