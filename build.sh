#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright (C) 2018 Raphiel Rollerscaperers (raphielscape)
# Copyright (C) 2018 Rama Bondan Prakoso (rama982)
# Android Kernel Build Script

# Main environtment
KERNEL_DIR=$PWD
KERN_IMG=$KERNEL_DIR/out/arch/arm64/boot/Image.gz-dtb
ZIP_DIR=$KERNEL_DIR/AnyKernel3
CONFIG=onc_defconfig

# Export
export ARCH=arm64
export CROSS_COMPILE
export CROSS_COMPILE_ARM32

# Main Staff

clang_bin="$HOME/toolchains/proton-clang/bin"
gcc_prefix64="aarch64-linux-gnu-"
gcc_prefix32="arm-linux-gnueabi-"
CROSS_COMPILE="aarch64-linux-gnu-"
CROSS_COMPILE_ARM32="arm-linux-gnueabi-"

_ksetup_old_path="$PATH"
export PATH="$clang_bin:$PATH"

# Index of variables for cleanup in unsetup
_ksetup_vars+=(
	clang_bin
	gcc_prefix64
	gcc_prefix32
	jobs
	kmake_flags
)

kmake_flags+=(
	CC="clang"
	AR="llvm-ar"
	NM="llvm-nm"
	OBJCOPY="llvm-objcopy"
	OBJDUMP="llvm-objdump"
	STRIP="llvm-strip"

	CROSS_COMPILE="$gcc_prefix64"
	CROSS_COMPILE_ARM32="$gcc_prefix32"
)

# Build start
make O=out $CONFIG
make -j$(nproc --all) O=out \
                      ARCH=arm64 \
                      CC=clang \

if ! [ -a $KERN_IMG ]; then
    echo "Build error!"
    exit 1
fi

cd $ZIP_DIR
make clean &>/dev/null
cd ..

# For MIUI Build
# Credit Adek Maulana <adek@techdro.id>
OUTDIR="$KERNEL_DIR/out/"
VENDOR_MODULEDIR="$KERNEL_DIR/AnyKernel3/modules/vendor/lib/modules"

STRIP="$HOME/toolchains/proton-clang/aarch64-linux-gnu/bin/strip$(echo "$(find "$HOME/toolchains/proton-clang/bin" -type f -name "aarch64-*-gcc")" | awk -F '/' '{print $NF}' |\
            sed -e 's/gcc/strip/')"
for MODULES in $(find "${OUTDIR}" -name '*.ko'); do
    "${STRIP}" --strip-unneeded --strip-debug "${MODULES}"
    "${OUTDIR}"/scripts/sign-file sha512 \
            "${OUTDIR}/certs/signing_key.pem" \
            "${OUTDIR}/certs/signing_key.x509" \
            "${MODULES}"
    find "${OUTDIR}" -name '*.ko' -exec cp {} "${VENDOR_MODULEDIR}" \;
done
cd libufdt/src && python mkdtboimg.py create $OUTDIR/arch/arm64/boot/dtbo.img $OUTDIR/arch/arm64/boot/dts/qcom/*.dtbo
echo -e "\n(i) Done moving modules"

cd $ZIP_DIR
cp $KERN_IMG zImage
cp $OUTDIR/arch/arm64/boot/dtbo.img $ZIP_DIR
make normal &>/dev/null
echo "Flashable zip generated under $ZIP_DIR."
cd ..
# Build end

