#!/bin/bash

echo "Encrypting an entire partition"
#The first step is to optionally fill the disk with random data, which is a good practice if it is likely that someone knowledgable is actually going to crack your encrypted data.  
#The downside is that it can take a long time if the partition is large.  
#For example, filling a 500 GB partition over a SATA II connection with a relatively fast CPU takes over 24 hours.  
#If you don’t have the time you can simply skip this step.  The worst part of the process is that there is no progress indicator, so you just wait for it to finish.

echo "lookup actual device name"

while true; do
    read -p "Do you know the name of your partition?" yn
    case $yn in
        [Yy]* ) echo "Enter its name, e.g. sdb" read partition; dd if=/dev/urandom of=/dev/$partition; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done
#Substitute /dev/sdb with the path to your device node.
echo "create the LUKS partition."
 
sudo cryptsetup -v --cipher aes-xts-plain64 --key-size 512 --hash sha512 --iter-time 5000 --use-random --verify-passphrase luksFormat /dev/$partition
#--cipher sets the cipher to be used by the encryption.  
#--key-size sets the encrypted key size.  256 is twice the default of 128. 
#--verify-passphrase causes luksFormat to ask for a passphrase twice, which is a good idea when formating to avoid typos.  luksFormat formats the partition /dev/sdb.

#Now that the partition has been formated, we need to open it up and create an ext4 partition inside it.
echo "open partition and create ext4 partition inside"

sudo cryptsetup luksOpen /dev/sdb encr-sdb
sudo mkfs.ext4 /dev/mapper/encr-sdb
#luksOpen will create a device under /dev/mapper named encr-sdb that we can use to access our encrypted partition.  To facilitate easy mounting of the container we can create an entry in fstab.

#/dev/mapper/encr-sdb        /mnt/encr-sdb       ext4            user,noauto             0       0
#You can, of course, use any options that you desire in your fstab entry.  In the future, to connect to the encrypted container, the following commands must be run.

#cryptsetup luksOpen /dev/sdb encr-sdb
#mount /dev/mapper/encr-sdb 
#luksOpen will prompt you for your password before proceeding.  To disconnect from the encrypted container, undo the commands in reverse.

#umount /dev/mapper/encr-sdb
#cryptsetup luksClose encr-sdb
#These commands can be scripted to facilitate easy access.
