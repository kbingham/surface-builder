#!/bin/bash

CHROMIUM_REPO=https://github.com/libcamera-org/chromium.git
CHROMIUM_BRANCH=surface

echo "Installing dependencies (Assuming ubuntu 20.04)"

echo "Chromium dependencies"
sudo apt install -y \
       gnome-keyring libva-dev libdri2-dev mesa-common-dev python python2.7

echo "Building chromium"

build_chromium() {
	## Does this help?
	git config --global index.threads $(nproc)
	git config --global pack.threads $(nproc)

	git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
	export PATH="$PATH:${HOME}/depot_tools"
	mkdir ~/chromium && cd ~/chromium
	fetch --nohooks chromium
	cd src
	sudo ./build/install-build-deps.sh --unsupported
	gclient runhooks

	git remote add github https://github.com/libcamera-org/chromium.git
	git fetch github
	git checkout -b surface github/surface
	gclient sync
	
	gn gen out/Default --args="is_debug=false is_component_build=true symbol_level=0 enable_nacl=false blink_symbol_level=0 use_gold=false use_sysroot=false is_clang=true clang_use_chrome_plugins=false use_lld=false is_clang=true use_custom_libcxx=true libcxx_abi_unstable=false use_gnome_keyring=false use_libcamera=true"
	 autoninja -C out/Default chrome

	mkdir -p ~/results
	tar czvf ~/results/chrome-build.tgz out/Default
}

time build_chromium