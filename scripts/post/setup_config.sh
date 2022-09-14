#!/bin/bash

chsh -s $(which zsh) "${username}"

# udev
cp -r $system_dir/udev/* /etc/udev/rules.d/
ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules

# xorg
cp -r $system_dir/xorg/* /etc/X11/xorg.conf.d/

# bin
chmod -R +x $system_dir/bin/*
cp -r $system_dir/bin/* /usr/local/bin/

# wallpapers
cp -r $install_dir/wallpapers/ "/home/${username}/.wallpapers/"
