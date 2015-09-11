#!/bin/bash


# dependencies: cryptsetup, cryptmount, dmsetup
echo "Encrypting a container within an existing filesystem"

sleep 5;
echo "create the encrypted container"
dd if=/dev/urandom of=$HOME/.ecnrypted/tresor bs=1024 count=5120000

# Maybe this kernel does not know about the loop device
#sudo modprobe loop

#Now we need to create a mapping between this file and a free loop device.  
#This step is needed because at the moment cryptsetup cannot use a file as a block device directly.  We can use losetup (part of util-linux) to find out which loop device is free with the command:
echo "create mapping between file and a free loop device"
sudo losetup -f

touch $HOME/.encrypted/tresor
#For me it was /dev/loop0. So, I map the "container1" file to /dev/loop0.
sudo losetup /dev/loop0 $HOME/.encrypted/tresor
echo "Once the loop device is mapped, we can encrypt the container."

sudo cryptsetup --verbose --cipher aes-xts-plain64 --key-size 512 --hash sha512 --iter-time 5000 --use-random --verify-passphrase luksFormat /dev/loop0 
#--verify-passphrase causes luksFormat to ask for a passphrase twice, which is a good idea when formating to avoid typos.  luksFormat formats /dev/loop0.

#Now that the contaner has been encrypted, we need to open it up and create an ext4 partition inside it.
echo "Open container and create ext4 partition inside"
sudo cryptsetup luksOpen /dev/loop0 encr-container
sudo mkfs.ext4 /dev/mapper/encr-container
#luksOpen will create a device under /dev/mapper named encr-container that we can use to access our container.  
#To facilitate easy mounting of the container we can create an entry in fstab.

#/dev/mapper/encr-container        /mnt/encr-mount       ext4            user,noauto             0       0
#You can, of course, use any options that you desire in your fstab entry.  In the future, to connect to the encrypted container, the following three commands must be run.

#losetup /dev/loop0 /path/to/container
#cryptsetup luksOpen /dev/loop0 encr-container
#mount /dev/mapper/encr-container
#luksOpen will prompt you for your password before proceeding.  To disconnect from the encrypted container, undo the commands in reverse.

#umount /dev/mapper/encr-container
#cryptsetup luksClose encr-container
#losetup -d /dev/loop0
#These commands can be scripted to facilitate easy access.
