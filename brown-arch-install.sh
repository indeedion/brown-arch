#!/bin/bash

#PURPOSE: Main install script for brown-arch base environment
#DEPENDENCIES: a clean functioning arch-install
#USAGE: Run this script with sudo logged in as user. DO NOT RUN AS ROOT!

#global vars
INSTALL_ROOT="$PWD"
user=$(whoami)
echo "root: $INSTALL_ROOT"

#get internet connection
dhcpcd

#test internet connection
if [ ! ping -c 2 8.8.8.8 ]; then
    echo "No connection to internet!"
    exit 1
fi

#upgrade system
echo "UPGRADING SYSTEM"
pacman -Syyu

#install basic packages
echo "INSTALLING BASIC PACKAGES"
packages=$(<arch-packages)
pacman -S $packages

#install vbox guest additions
pacman -S virtualbox-guest-iso
mkdir -p /mnt/vboxiso
mount /usr/lib/virtualbox/additions/VBoxGuestAdditions.iso /mnt/vboxiso
cp /mnt/vboxiso/VBoxLinuxAdditions.run /tmp
chmod +x /tmp/VBoxLinuxAdditions.run
cd /tmp
./VBoxLinuxAdditions.run

#add blackarch repository
cd $INSTALL_ROOT
curl -O https://blackarch.org/strap.sh
#check sha1sum, should match 9f770789df3b7803105e5fbc19212889674cd503
sum="9f770789df3b7803105e5fbc19212889674cd503 strap.sh" 

res=`sha1sum --check <<END
$sum
END` 
if [ "$res" != 'strap.sh: OK' ]; then
     echo "blackarch strap.sh sha1sum is NOT valid!"
     exit 1
else
    echo "blackarch strap.sh sha1sum is valid."
fi

chmod +x $INSTALL_ROOT/strap.sh
./strap.sh

#install basic pentesting tools
echo "INSATLLING PeNtEsTiNg TOOLS"
packages=$(<barch-packages)
pacman -S $packages


#set banner of the day
echo "Welcome to the brownest arch!" > /etc/motd

#setting up x
cd
cp /etc/X11/xinit/xinitrc ./.xinitrc
touch .Xauthority
sed '/^twm/d' .xinitrc
sed '/^xclock/d' .xinitrc
sed '/^xterm/d' .xinitrc
sed '/^exec/d' .xinitrc
echo "exec i3" >> .xinitrc

#TO BE CONTINUED
#do hardening stuff here


