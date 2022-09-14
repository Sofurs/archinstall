#!/bin/bash

su -l "${username}"
mkdir -p "~/.local/gitinstall/"
git clone https://github.com/Sofurs/dotfiles.git ~/.local/gitinstall/
ln -s "/home/${username}/.local/gitinstall/dotfiles/" "/home/${username}/.config"

git clone https://github.com/Sofurs/dwm.git ~/.local/gitinstall/
git clone https://github.com/Sofurs/st.git ~/.local/gitinstall/

make -C ~/.local/gitinstall/dwm
make -C ~/.local/gitinstall/st
exit

make -C ~/.local/gitinstall/dwm install
make -C ~/.local/gitinstall/st install