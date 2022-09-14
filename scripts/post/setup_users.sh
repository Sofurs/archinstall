#!/bin/bash

chpasswd <<< "root:${root_passwd}"

useradd -m "${username}" -G wheel
chpasswd <<< "${username}:${user_passwd}"

sed -i 's/# %wheel ALL=(ALL:ALL) ALL$/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
sed -i '/%wheel ALL=(ALL:ALL) ALL$/a %wheel ALL=(ALL:ALL) NOPASSWD: /usr/bin/mount' /etc/sudoers

echo 'permit :wheel' > /etc/doas.conf