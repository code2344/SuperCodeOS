#!/bin/bash
# build script

echo "Building CircleOS..."

echo "clearing old version"
rm -rf build
mkdir build

echo "assembling CircleOS..."

nasm kernel.asm -o build/kernel.bin
if [ $? -ne 0 ]; then
    echo "Error assembling kernel.asm"
    exit 1
fi
echo "kernel.asm assembled successfully"

KERNEL_SIZE=$(stat -f%z "build/kernel.bin")
KERNEL_SECTORS=$(( (KERNEL_SIZE + 511) / 512 ))
echo "Kernel size: $KERNEL_SIZE bytes, which is $KERNEL_SECTORS sectors"

nasm -DKERNEL_SECTORS=$KERNEL_SECTORS boot.asm -o build/boot.bin
if [ $? -ne 0 ]; then
    echo "Error assembling boot.asm"
    exit 1
fi
echo "boot.asm assembled successfully"


echo "creating disk image"
dd if=/dev/zero of=build/circleos.img bs=512 count=2880 2>/dev/null

echo "writing bootloader to disk image"
dd if=build/boot.bin of=build/circleos.img bs=512 count=1 conv=notrunc 2>/dev/null

echo "writing kernel to disk image"
dd if=build/kernel.bin of=build/circleos.img bs=512 seek=1 count=$KERNEL_SECTORS conv=notrunc 2>/dev/null

echo "CircleOS built successfully! Disk image created at build/circleos.img"