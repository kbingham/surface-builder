#!/bin/bash

echo "Libcamera dependencies"

sudo apt install -y \
	build-essential meson ninja-build pkg-config libgnutls28-dev openssl \
	python3-pip python3-yaml python3-ply python3-jinja2 \
	qtbase5-dev libqt5core5a libqt5gui5 libqt5widgets5 qttools5-dev-tools \
	libtiff-dev libevent-dev \
	clang libc++-dev libc++abi-dev

sudo pip3 install meson
sudo pip3 install --upgrade meson


echo "Building libcamera"

build_libcamera() {
	git clone https://github.com/libcamera-org/libcamera.git -b surface
	cd libcamera
	CC=clang CXX=clang++ meson build -Dpipelines=uvcvideo,ipu3 -Dprefix=/usr -Dtest=false
	ninja -C build
	sudo ninja -C build install
	sudo ldconfig
	cd ..
}

time build_libcamera
