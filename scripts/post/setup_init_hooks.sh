#!/bin/bash

if [ "$encryption" = true ]; then
    sed -i '/^HOOKS/s/filesystems //' /etc/mkinitcpio.conf
    sed -i '/^HOOKS/s/)/ keymap encrypt openswap resume filesystems)/' /etc/mkinitcpio.conf

    envsubst '${part2}' < $system_dir/openswap/openswap_hook > /etc/initcpio/hooks/openswap
    envsubst < $system_dir/openswap/openswap_install > /etc/initcpio/install/openswap
fi

mkinitcpio -P
