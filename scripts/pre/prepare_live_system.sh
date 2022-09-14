#!/bin/bash

# check for internet connection
ping -c5 google.com

if [ $? -ne 0 ]; then
    echo "No internet connection. Ping return code: $?.";
    exit 1;
fi

timedatectl set-ntp true # set time
setfont ter-218b -m 8859-2 # set console font

# update mirrors
reflector --protocol https --latest 10 --save /etc/pacman.d/mirrorlist
sed -i 's/#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf

pacman -Sy
pacman -S --needed --noconfirm dos2unix

find "$script_dir/post_installation/config/"{openswap,udev,xorg} -type f -exec dos2unix {} \;