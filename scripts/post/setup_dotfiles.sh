#!/bin/bash

rm "/home/${username}/.bash"*

cp -r $dotfile_dir/.* "/home/${username}"
chown -R "${username}:${username}" "/home/${username}"

cp -r $dotfile_dir/ "/home/${username}/.config/"
rm "/home/${username}/.config/."*

curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim


