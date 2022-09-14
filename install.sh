#!/bin/bash

export dir_name="archinstall"
export install_dir="$HOME/$dir_name"
export script_dir="$install_dir/scripts"
export pre_dir="$script_dir/pre"
export post_dir="$script_dir/post"
export dotfile_dir="$install_dir/dotfiles"
export system_dir="$install_dir/system_config"

# set -euxo pipefail

source $install_dir/config.conf

$pre_dir/prepare_live_system.sh
source $pre_dir/partition_disks.sh

# install
pacstrap /mnt base linux linux-firmware reflector

# generate system fstab
genfstab -U /mnt >> /mnt/etc/fstab

cp -r $install_dir /mnt/root/
( arch-chroot /mnt $script_dir/post_installation.sh )
rm -rdf "/mnt/root/$dir_name"

echo "Installation has finished, press enter to reboot..."
IFS=
read -n1 key

umount -R /mnt
reboot
