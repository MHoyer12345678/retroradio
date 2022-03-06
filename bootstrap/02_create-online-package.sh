#!/bin/bash

RFS_DIR=/var/nfs/rfs
ONLINE_PKG_DIR=$RFS_DIR/root/online-package
KNL_PKG_DST_DIR=$ONLINE_PKG_DIR/kernel

APT_SRCS_DST_DIR=$ONLINE_PKG_DIR/apt-sources
APT_SRCS_FILES=files/*.list

NET_SETUP_DST_DIR=$ONLINE_PKG_DIR/network-setup
NET_SETUP_FILES=network-setup/*

PATCH_FILES_DST_DIR=$ONLINE_PKG_DIR/patch_dir
PATCH_FILES=patch_dir/*

ADDITIONAL_FILES="files/files-to-remove-from-rfs.conf"

TIMESTAMP_DST=$ONLINE_PKG_DIR/time.txt

ONLINE_SCRIPTS="05_install-kernel.sh 06_setup-wifi.sh 07_install-software.sh"

if [ $UID -ne 0 ]; then
    echo "Please run as root ..."
    exit 1
fi

# check if cross kernel config file is set
if [ "${KNL_SCRIPTS_CONF_FILE}" != "" ]; then
    echo "Kernel package Configuration file is set to: ${KNL_SCRIPTS_CONF_FILE}"
    echo "Using it."
    source ${KNL_SCRIPTS_CONF_FILE} || exit 1
fi

echo "---------------- Putting Online Package into bootstrap RFS -----------------------------------"
echo "Online package dir: $ONLINE_PKG_DIR"

# if KNL_PKG_BASE_DIR is not set (in config files), use default path
if [ "$KNL_PKG_BASE_DIR" == "" ]; then
    echo "KNL_PKG_BASE_DIR is not set. Do not add kernel to online package."
else
    echo "Kernel package to add: $KNL_PKG_BASE_DIR"
fi
echo "----------------------------------------------------------------------------------------------"

echo "Going to empty existing online package in 5 secs"

sleep 5

# preparing online package dir
echo "Emptying existing package"

rm -r $ONLINE_PKG_DIR

echo "Creating new package"
mkdir $ONLINE_PKG_DIR || exit 1

# installing kernel pkg
if [ "$KNL_PKG_BASE_DIR" == "" ]; then
    echo "Skipping kernel online package."
else
    echo "Adding kernel package"
    mkdir -p $KNL_PKG_DST_DIR || exit 1
    cp -r $KNL_PKG_BASE_DIR $KNL_PKG_DST_DIR/ || exit 1
fi

# installing apt sources configs
echo "Adding apt sources to package ..."
mkdir -p $APT_SRCS_DST_DIR || exit 1
cp $APT_SRCS_FILES $APT_SRCS_DST_DIR/ || exit 1

# installing network setup files
echo "Adding network setup artefacts to package ..."
mkdir -p $NET_SETUP_DST_DIR || exit 1
cp $NET_SETUP_FILES $NET_SETUP_DST_DIR/ || exit 1

# installing files to patch the rfs
echo "Adding files to patch to package ..."
mkdir -p $PATCH_FILES_DST_DIR || exit 1
cp -r $PATCH_FILES $PATCH_FILES_DST_DIR/ || exit 1

# installing online scripts
echo "Adding online scripts ..."
cp $ONLINE_SCRIPTS $ONLINE_PKG_DIR/ || exit 1

# copying additional files to online package
echo "Adding additional files ..."
cp $ADDITIONAL_FILES  $ONLINE_PKG_DIR/ || exit 1

echo "Adding time stamp to online package ..."
date -R > $TIMESTAMP_DST || exit 1

echo "Done"
