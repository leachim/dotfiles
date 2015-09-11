#!/bin/sh
umount /dev/mapper/encr-container
sudo cryptsetup luksClose encr-container
sudo losetup -d /dev/loop0
