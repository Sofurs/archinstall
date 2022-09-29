#!/bin/bash

export dir_name="archinstall"
export install_dir="$HOME/$dir_name"
export script_dir="$install_dir/scripts"
export dotfile_dir="$install_dir/dotfiles"
export system_dir="$install_dir/dotfiles/system"

# set -euxo pipefail

source $install_dir/config.conf

source $script_dir/pre.sh

# install
pacstrap /mnt base linux linux-firmware reflector

# generate system fstab
genfstab -U /mnt >> /mnt/etc/fstab

cp -r $install_dir /mnt/root/
( arch-chroot /mnt $script_dir/post.sh)
rm -rdf "/mnt/root/$dir_name"

echo "Installation has finished, press enter to reboot..."
IFS=
read -n1 key

umount -R /mnt
reboot
