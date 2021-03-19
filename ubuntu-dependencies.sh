#!/bin/sh

apt update; apt upgrade -y; apt install sudo;

sudo apt install -y \
	build-essential meson ninja-build pkg-config libgnutls28-dev openssl \
	python3-pip python3-yaml python3-ply python3-jinja2 \
	qtbase5-dev libqt5core5a libqt5gui5 libqt5widgets5 qttools5-dev-tools \
	libtiff-dev libevent-dev \
	clang libc++-dev libc++abi-dev \
        gnome-keyring libva-dev libdri2-dev libx11-xcb-dev mesa-common-dev python python2.7

sudo pip3 install meson
sudo pip3 install --upgrade meson
