#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2018 Raphiel Rollerscaperers (raphielscape)
# Copyright (C) 2018 Rama Bondan Prakoso (rama982)
# Android Kernel Build Script

# Clone AnyKernel3
git clone https://github.com/johnmart19/AnyKernel3 -b olive Anykernel3

#Download Clang
if [ ! -d $HOME/toolchains/proton-clang ]; then
mkdir $HOME/toolchains
git clone https://github.com/kdrag0n/proton-clang $HOME/toolchains/proton-clang --depth=1
fi

# Download libufdt
if [ ! -d libufdt ]; then
    wget https://android.googlesource.com/platform/system/libufdt/+archive/refs/tags/android-10.0.0_r45/utils.tar.gz
    mkdir -p libufdt
    tar xvzf utils.tar.gz -C libufdt
    rm utils.tar.gz
fi
