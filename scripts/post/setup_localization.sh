#!/bin/bash

# time and localization setup
ln -sf /usr/share/zoneinfo/${timezone} /etc/localtime
hwclock --systohc
sed -i -e 's/#en_US/en_US/' -e 's/#sk_SK/sk_SK/' /etc/locale.gen
locale-gen

# setup console font and keymap
cat << EOF > /etc/vconsole.conf
FONT=ter-218b
FONT_MAP=8859-2 
EOF