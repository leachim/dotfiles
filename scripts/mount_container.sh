#!/bin/sh
echo "enter path to encrypted container"
read path
sudo losetup /dev/loop0 $path
sudo cryptsetup luksOpen /dev/loop0 encr-container
mount /dev/mapper/encr-container
