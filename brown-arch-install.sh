#!/bin/bash

#PURPOSE: Main install script for brown-arch environment
#DEPENDENCIES: a clean functioning arch-install

#global vars
TMP_PATH="$PWD"

#adding user
read -p "Username: " user
groupadd $user
useradd -g $user $user
passwd $user

#get internet connection
dhcpcd

#test internet connection
if [ ! ping -c2 8.8.8.8 ]; then
    echo "No connection to internet!"
    exit 1
fi

#upgrade system
pacman -Syyu

#install basic packages
pacman -S freetype2 libglvnd ffmpeg
pacman -S xorg xorg-xinit

packages="ranger nitrogen i3-gaps rxvt-unicode qutebrowser xcompmgr git vim openssl
openssh i3blocks alsa-utils pulseaudio pavucontrol linux-headers gcc make perl sudo i3status
irssi xdotool dmenu"

pacman -S $packages

#create home directory tree
mkdir -p /home/$user
mkdir -p /home/$user/Desktop
mkdir -p /home/$user/Documents
mkdir -p /home/$user/Pictures
mkdir -p /home/$user/Downloads

#install vbox guest additions
packages="virtualbox-guest-iso virtualbox-guest-modules-arch"
pacman -S $packages
if pacman -Qi "$packages"; then	
    mkdir -p /mnt/vboxtmp
    mount /usr/lib/virtualbox/additions/VBoxGuestAdditions.iso /mnt/vboxtmp
    cp /mnt/vboxtmp/VBoxLinuxAdditions.run /tmp
    cd /tmp
    ./VBoxLinuxAdditions.run &&
    umount /mnt/vboxtmp
    rm VBoxLinuxAdditions.run
else
    echo "virtualbox guest packages failed to install"
fi

#setup sudo
sed -i "/root ALL=(ALL) ALL/a$user ALL=(ALL) ALL" /etc/sudoers
groupadd sudo
usermod -a -G sudo $user

#add blackarch repository
cd /tmp
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

chmod +x strap.sh
./strap.sh

#install basic pentesting tools
packages="nmap aircrack-ng hydra john"
if [ ! pacman -S $packages ]; then
    echo "failed to install some or alla haxor packages"
fi

#set banner of the day
echo "Welcome to the brownest arch!" > /etc/motd

#install fonts
mkdir -p /usr/share/fonts/TTF
cp fonts/TTF/* /usr/share/fonts/TTF

#TO BE CONTINUED
#do hardening stuff here


