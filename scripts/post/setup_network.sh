#!/bin/bash

echo "${hostname}" > /etc/hostname

systemctl enable NetworkManager
cp "$system_dir/NetworkManager/dispatcher.d/"* /etc/NetworkManager/dispatcher.d/
