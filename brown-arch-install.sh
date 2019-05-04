#!/bin/bash

#PURPOSE: Main install script for brown-arch base environment
#DEPENDENCIES: a clean functioning arch-install
#USAGE: Run this script with sudo logged in as user. DO NOT RUN AS ROOT!

#global vars
INSTALL_ROOT="$PWD"

read -p "Install brownarch to user: " user

#get internet connection
dhcpcd

#test internet connection DOES NOT WORK, needs fixing
#if [ ! $(ping -c 2 8.8.8.8) ]; then
#    echo "No connection to internet!"
#    exit 1
#fi

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
echo "INSTALLING PeNtEsTiNg TOOLS"
packages=$(<barch-packages)
pacman -S $packages


#set banner of the day
echo "Welcome to the brownest arch!" > /etc/motd

#install configs
cd $INSTALL_ROOT/cfg
cp nanorc /home/$user/.nanorc
cp vimrc /home/$user/.vimrc
cp Xresources /home/$user/.Xresources
cp xinitrc /home/$user/.xinitrc
touch /home/$user/.Xauthority

mkdir -p /home/$user/.config/i3blocks
mkdir -p /home/$user/.config/i3
mkdir -p /home/$user/Pictures/wallpapers
mkdir -p /home/$user/.brownarch/bin
cp i3blocks_cfg /home/$user/.config/i3blocks/config
cp i3config /home/$user/.config/i3/config
cp $INSTALL_ROOT/walls/* /home/$user/Pictures/wallpapers
cp $INSTALL_ROOT/bin/* /home/$user/.brownarch/bin
cp $INSTALL_ROOT/fonts/* /usr/share/fonts/TTF

#give user rights to home folder
chown -R $user:$user /home/$user

#framebuffer resolution for grub(needed for fullscreen in virtualbox)
sed -i '/GRUB_GFXMODE=/c\GRUB_GFXMODE=1920x1080x24' /etc/default/grub
sed -i '/GRUB_GFXPAYLOAD_LINUX=/c\GRUB_GFXPAYLOAD_LINUX=keep' /etc/default/grub

#TO BE CONTINUED
#do hardening stuff here

