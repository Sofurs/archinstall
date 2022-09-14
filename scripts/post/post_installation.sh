#!/bin/bash


reflector --protocol https --latest 10 --save /etc/pacman.d/mirrorlist
sed -i 's/#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

$post_dir/setup_localization.sh

# update package database
pacman -Sy
pacman -S --noconfirm --needed git base-devel vim networkmanager dhclient sudo opendoas

$post_dir/setup_init_hooks.sh
$post_dir/setup_boot.sh
$post_dir/setup_users.sh
$post_dir/setup_network.sh
$post_dir/install_packages.sh
$post_dir/setup_config.sh
