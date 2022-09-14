#!/bin/bash

pacman -S --noconfirm --needed grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub

if [ "$encryption" = true ]; then
    sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT/s/\"$/ cryptdevice=UUID=$(blkid -s UUID -o value ${part3}):root root=\/dev\/mapper\/root resume=UUID=$(blkid -s UUID -o value /dev/mapper/swap)\"/" /etc/default/grub
    sed -i 's/^#GRUB_DISABLE_OS_PROBER/GRUB_DISABLE_OS_PROBER/' /etc/default/grub
fi

grub-mkconfig -o /boot/grub/grub.cfg

# secureboot setup
# pacman -S --noconfirm --needed efitools sbsigntools

# backup existing keys
# mkdir ${HOME}/key_backup/
# efi-readvar -v PK -o ${HOME}/key_backup/old_PK.esl
# efi-readvar -v KEK -o ${HOME}/key_backup/old_KEK.esl
# efi-readvar -v db -o ${HOME}/key_backup/old_db.esl
# efi-readvar -v dbx -o ${HOME}/key_backup/old_dbx.esl
# 
# mkdir -p /usr/share/secureboot/keys
# cd /usr/share/secureboot/keys
#  
# uuidgen --random > /tmp/GUID.txt
# openssl req -newkey rsa:4096 -nodes -keyout PK.key -new -x509 -sha256 -days 3650 -subj "/CN=my Platform Key/" -out PK.crt
# openssl x509 -outform DER -in PK.crt -out PK.cer
# cert-to-efi-sig-list -g "$(< GUID.txt)" PK.crt PK.esl
# sign-efi-sig-list -g "$(< GUID.txt)" -k PK.key -c PK.crt PK PK.esl PK.auth
# sign-efi-sig-list -g "$(< GUID.txt)" -k PK.key -c PK.crt -k PK.key PK /dev/null rm_PK.auth
# 
# openssl req -newkey rsa:4096 -nodes -keyout KEK.key -new -x509 -sha256 -days 3650 -subj "/CN=my Key Exchange Key/" -out KEK.crt
# openssl x509 -outform DER -in KEK.crt -out KEK.cer
# cert-to-efi-sig-list -g "$(< GUID.txt)" KEK.crt KEK.esl
# sign-efi-sig-list -g "$(< GUID.txt)" -k PK.key -c PK.crt KEK KEK.esl KEK.auth
# 
# openssl req -newkey rsa:4096 -nodes -keyout db.key -new -x509 -sha256 -days 3650 -subj "/CN=my Signature Database Key" -out db.crt
# openssl x509 -outform DER -in db.crt -out db.cer
# cert-to-efi-sig-list -g "$(< GUID.txt)" db.crt db.esl
# sign-efi-sig-list -g "$(< GUID.txt)" -k KEK.key -c KEK.crt db db.esl db.auth
# 
# sbsign --key db.key --cert db.crt --output /boot/vmlinuz-linux /boot/vmlinuz-linux
# sbsign --key db.key --cert db.crt --output /boot/EFI/BOOT/BOOTX64.EFI /boot/EFI/BOOT/BOOTX64.EFI
# cp /usr/share/secureboot/keys/*.cer /usr/share/secureboot/keys/*.esl /usr/share/secureboot/keys/*.auth /boot/EFI
# 
# cd /

# auto signing setup
# cp /usr/share/libalpm/hooks/90-mkinitcpio-install.hook /etc/pacman.d/hooks/90-mkinitcpio-install.hook
# cp /usr/share/libalpm/scripts/mkinitcpio-install /usr/local/share/libalpm/scripts/mkinitcpio-install
# 
# sed -i 's%Exec = /usr/share/libalpm/scripts/mkinitcpio-install%Exec = /usr/local/share/libalpm/scripts/mkinitcpio-install%' /etc/pacman.d/hooks/90-mkinitcpio-install.hook
# sed -i 's%install -Dm644 "${line}" "/boot/vmlinuz-${pkgbase}"%sbsign --key /usr/share/secureboot/keys/db.key --cert /usr/share/secureboot/keys/db.crt --output "/boot/vmlinuz-${pkgbase}" "${line}"%' /usr/local/share/libalpm/scripts/mkinitcpio-install
