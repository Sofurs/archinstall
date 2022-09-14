#!/bin/bash

# partition disks
sgdisk -Z ${disk}
sgdisk -a 2048 -o ${disk}

sgdisk -n 1::+300M --typecode=1:ef00 --change-name=1:'efi' ${disk}
sgdisk -n 2::+${swap_size} --typecode=2:8200 --change-name=2:'swap' ${disk}
sgdisk -n 3::-0 --typecode=3:8300 --change-name=3:'root' ${disk}

partprobe ${disk}

if [[ "${disk}" =~ "nvme" ]]; then
    export part1="${disk}p1"
    export part2="${disk}p2"
    export part3="${disk}p3"
else
    export part1="${disk}1"	
    export part2="${disk}2"	
    export part3="${disk}3"	
fi

if [[ "$encryption" == true ]]; then
    echo -n "${root_password}" | cryptsetup -q luksFormat ${part3} -
    echo -n "${root_password}" | cryptsetup luksOpen ${part3} root -
    echo -n "${swap_password}" | cryptsetup -q luksFormat ${part2} -
    echo -n "${swap_password}" | cryptsetup luksOpen ${part2} swap -
    mkfs.fat -F 32 ${part1}
    mkswap /dev/mapper/swap
    mkfs.ext4 /dev/mapper/root

    mount /dev/mapper/root /mnt
    mount --mkdir ${part1} /mnt/boot
    swapon /dev/mapper/swap
else
    mkfs.fat -F 32 ${part1}
    mkswap ${part2}
    mkfs.ext4 ${part3}

    mount ${part3} /mnt
    mount --mkdir ${part1} /mnt/boot
    swapon ${part2}
fi

if [[ "$encryption" == true ]]; then
    mkdir /mnt/crypt_keys
    echo -n "${swap_password}" > /mnt/crypt_keys/swap_key
    chmod -R 440 /mnt/crypt_keys/
    chattr +i /mnt/crypt_keys/swap_key
fi
