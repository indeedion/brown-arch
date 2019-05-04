#!/bin/bash

#PURPOSE: Main install script for brown-arch base environment
#DEPENDENCIES: a clean functioning arch-install
#USAGE: Run this script with sudo logged in as user. DO NOT RUN AS ROOT!

#global vars
INSTALL_ROOT="$PWD"
IS_VIRTUAL="false"

clear
echo "WELCOME"
echo "Welcome to the brown arch installer!"
echo "Brown arch can be installed as a regular host or as a virtualbox guest."
echo "While the install should work on other virtual platforms, such as VMware," 
echo " it does not install any drivers or guest additions for such a platform."
echo "If you install to a different platform than a regular host or "
echo "a virtualbox guest machine, you will have to install guest additions and/or drivers yourself."

echo "CHOOSE EXISTING USER"
read -p "Install brownarch to user: " user

#get internet connection
dhcpcd

#test internet connection DOES NOT WORK, needs fixing
#if [ ! $(ping -c 2 8.8.8.8) ]; then
#    echo "No connection to internet!"
#    exit 1
#fi

#upgrade system
clear
echo "UPGRADING SYSTEM"
pacman -Syyu

#install basic packages
clear
echo "INSTALLING BASIC PACKAGES"
packages=$(<arch-packages)
yes | pacman -S $packages

clear
echo "VIRTUALIZATION"
read -p "for the moment brownarch only supports virtualbox as hypervisor, are you installing to
a virtualbox machine? [yes/no]: " virtual

function install_virt(){
    #installs virtualbox guest additions
    IS_VIRTUAL="true"

    pacman -S virtualbox-guest-iso
    mkdir -p /mnt/vboxiso
    mount /usr/lib/virtualbox/additions/VBoxGuestAdditions.iso /mnt/vboxiso
    cp /mnt/vboxiso/VBoxLinuxAdditions.run /tmp
    chmod +x /tmp/VBoxLinuxAdditions.run
    cd /tmp
    ./VBoxLinuxAdditions.run
}

case $virtual in
    yes)
	install_virt
	;;
    y)
	install_virt
	;;
    Y)
	install_virt
	;;
    YES)
	install_virt
	;;
    Yes)
	install_virt
	;;
    *)
	;;
esac
>>>>>>> f995c4992cee3fd8ad0d16846beb1dec271d5e59

#add blackarch repository
clear
echo "INSTALLING BLACK ARCH"
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
clear
echo "INSTALLING PeNtEsTiNg TOOLS"
packages=$(<barch-packages)
yes | pacman -S $packages

# enable network manager
systemctl enable NetworkManager
systemctl start NetworkManager

#set banner of the day
echo "Welcome to the brownest arch!" > /etc/motd

#install configs
cd $INSTALL_ROOT/cfg
cp .nanorc /home/$user/
cp .vimrc /home/$user/
cp .Xresources /home/$user/
cp .xinitrc /home/$user/
cp .Xauthority /home/$user/
cp .bash_profile /home/$user/
cp .bashrc /home/$user/

mkdir -p /home/$user/.config/i3blocks
mkdir -p /home/$user/.config/i3
mkdir -p /home/$user/Pictures/wallpapers
mkdir -p /home/$user/.brownarch/bin
mkdir -p /usr/share/fonts/TTF
cp i3blocks_cfg /home/$user/.config/i3blocks/config
cp i3config /home/$user/.config/i3/config
cp $INSTALL_ROOT/walls/* /home/$user/Pictures/wallpapers
cp $INSTALL_ROOT/bin/* /home/$user/.brownarch/bin
cp $INSTALL_ROOT/fonts/* /usr/share/fonts/TTF

#give user rights to home folder
chown -R $user:$user /home/$user

#framebuffer resolution for grub(needed for fullscreen in virtualbox)
if [ $IS_VIRTUAL = "true"  ]; then
    sed -i '/GRUB_GFXMODE=/c\GRUB_GFXMODE=1920x1080x24' /etc/default/grub
    sed -i '/GRUB_GFXPAYLOAD_LINUX=/c\GRUB_GFXPAYLOAD_LINUX=keep' /etc/default/grub
fi

#TO BE CONTINUED
#do hardening stuff here

