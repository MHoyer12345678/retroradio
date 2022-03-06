#!/bin/bash

WIFI_SETUP_PKG="network-setup/network-setup_1.0.0_all.deb"
WIFI_CONF_FILE="network-setup/wpa_supplicant-wlan0.conf"


if [ $UID -ne 0 ]; then
    echo "Please run as root ..."
    exit 1
fi

echo "Setting up wifi ..."

timeToSet=$(cat time.txt)
date -s "${timeToSet}"

echo "Installing network setup package ${WIFI_SETUP_PKG} ..."
dpkg -i "${WIFI_SETUP_PKG}"

echo "Copying wpa_supplicant configuration file into rfs"
cp ${WIFI_CONF_FILE} /etc/wpa_supplicant/

echo "Starting wifi setup ..."
systemctl enable setup-wifi@wlan0.service
systemctl start setup-wifi@wlan0.service
