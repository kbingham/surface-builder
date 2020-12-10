#!/bin/sh

sudo apt-get install -y build-essential git bc flex bison libelf-dev libssl-dev
git clone --depth=1 https://github.com/torvalds/linux.git
cd linux;
make allyesconfig
make -j$(nproc)

ls arch/x86/boot/bzImage
