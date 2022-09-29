#!/bin/bash


reflector --protocol https --latest 10 --save /etc/pacman.d/mirrorlist
sed -i 's/#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

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

# update package database
pacman -Sy
pacman -S --noconfirm --needed git base-devel vim networkmanager dhclient sudo opendoas

# Init Hooks
if [ "$encryption" = true ]; then
    sed -i '/^HOOKS/s/filesystems //' /etc/mkinitcpio.conf
    sed -i '/^HOOKS/s/)/ keymap encrypt openswap resume filesystems)/' /etc/mkinitcpio.conf

    envsubst '${part2}' < $system_dir/openswap/openswap_hook > /etc/initcpio/hooks/openswap
    envsubst < $system_dir/openswap/openswap_install > /etc/initcpio/install/openswap
fi

mkinitcpio -P

# Setup Boot
pacman -S --noconfirm --needed grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub

if [ "$encryption" = true ]; then
    sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT/s/\"$/ cryptdevice=UUID=$(blkid -s UUID -o value ${part3}):root root=\/dev\/mapper\/root resume=UUID=$(blkid -s UUID -o value /dev/mapper/swap)\"/" /etc/default/grub
    sed -i 's/^#GRUB_DISABLE_OS_PROBER/GRUB_DISABLE_OS_PROBER/' /etc/default/grub
fi

grub-mkconfig -o /boot/grub/grub.cfg

# Setup Users
chpasswd <<< "root:${root_passwd}"

useradd -m "${username}" -G wheel
chpasswd <<< "${username}:${user_passwd}"

sed -i 's/# %wheel ALL=(ALL:ALL) ALL$/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers
sed -i '/%wheel ALL=(ALL:ALL) ALL$/a %wheel ALL=(ALL:ALL) NOPASSWD: /usr/bin/mount' /etc/sudoers

echo 'permit :wheel' > /etc/doas.conf

# Setup Network
echo "${hostname}" > /etc/hostname

systemctl enable NetworkManager
cp "$system_dir/NetworkManager/dispatcher.d/"* /etc/NetworkManager/dispatcher.d/

# Install Packages
pacman -S --needed --noconfirm xorg xorg-server xorg-xinit picom gtk-2 gtk-3 
pacman -S --needed --noconfirm man-db man-pages
pacman -S --needed --noconfirm zsh alacritty putty
pacman -S --needed --noconfirm mc ranger nautilus rofi
pacman -S --needed --noconfirm vi vim code
pacman -S --needed --noconfirm lshw htop btop usbutils power-profiles-daemon
pacman -S --needed --noconfirm fd ripgrep rsync wget
pacman -S --needed --noconfirm net-tools inetutils bind traceroute nmap nm-connection-editor avahi
pacman -S --needed --noconfirm alsa-utils pavucontrol pamixer pulseaudio pulseaudio-alsa
pacman -S --needed --noconfirm gimp feh maim xclip qiv imagemagick time
pacman -S --needed --noconfirm chromium firefox thunderbird libreoffice-fresh
pacman -S --needed --noconfirm networkmanager-l2tp networkmanager-openvpn networkmanager-openconnect capnet-assist
pacman -S --needed --noconfirm remmina libvncserver spice-gtk freerdp
pacman -S --needed --noconfirm vlc mpv ffmpeg obs-studio mpc
pacman -S --needed --noconfirm font-manager terminus-font ttf-dejavu ttf-droid ttf-fira-mono ttf-fira-code ttf-opensans ttf-joypixels ttf-ubuntu-font-family papirus-icon-theme
pacman -S --needed --noconfirm okular zathura zathura-pdf-poppler mupdf simple-scan xsane
pacman -S libvirt iptables-nft dnsmasq dmidecode bridge-utils openbsd-netcat gnome-boxes virt-manager virt-viewer

pacman -S --needed --noconfirm flac wavpack a522dec libmad lame opus opencore-amr speex libmpcdec
pacman -S --needed --noconfirm dav1d rav1e libdv x265 x264 libmpeg2 xvidcore libtheora libvpx
pacman -S --needed --noconfirm jasper libwebp libavif libheif

pacman -S --needed --noconfirm file-roller tar binutils bzip2 gzip lz4 lrzip xz zip unzip unrar p7zip

pacman -S --needed --noconfirm util-linux gptfdisk parted gpart testdisk
pacman -S --needed --noconfirm btrfs-progs dosfstools exfatprogs e2fsprogs ntfs-3g

pacman -S --needed --noconfirm php7
pacman -S --needed --noconfirm jq dbeaver gnupg scrypt
pacman -S --needed --noconfirm bc gnome-calculator arandr lxappearance-gtk3
pacman -S --needed --noconfirm cups cups-pdf system-config-printer hplip
pacman -S --needed --noconfirm imlib2 # dwm icon dependency

# setup mkconf
nc=$(grep -c ^processor /proc/cpuinfo)
sed -i "s/#MAKEFLAGS=\"-j2\"/MAKEFLAGS=\"-j$nc\"/g" /etc/makepkg.conf
sed -i "s/COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T $nc -z -)/g" /etc/makepkg.conf

# installing microcode and grub and gpu drivers
proc_type=$(lscpu)
if grep -E "GenuineIntel" <<< ${proc_type}; then
    pacman -S --noconfirm --needed intel-ucode
elif grep -E "AuthenticAMD" <<< ${proc_type}; then
    pacman -S --noconfirm --needed amd-ucode
fi

gpu_type=$(lspci)
if grep -E "NVIDIA|GeForce" <<< ${gpu_type}; then
    pacman -S --noconfirm --needed nvidia
    nvidia-xconfig
elif lspci | grep 'VGA' | grep -E "Radeon|AMD"; then
    pacman -S --noconfirm --needed xf86-video-amdgpu
elif grep -E "Integrated Graphics Controller" <<< ${gpu_type}; then
    pacman -S --noconfirm --needed libva-intel-driver libvdpau-va-gl lib32-vulkan-intel \
        vulkan-intel libva-intel-driver libva-utils lib32-mesa
elif grep -E "Intel Corporation UHD" <<< ${gpu_type}; then
    pacman -S --needed --noconfirm libva-intel-driver libvdpau-va-gl lib32-vulkan-intel \
        vulkan-intel libva-intel-driver libva-utils lib32-mesa
elif grep -E "Intel Corporation Iris" <<< ${gpu_type}; then
    pacman -S --needed --noconfirm libva-intel-driver libvdpau-va-gl lib32-vulkan-intel \
        vulkan-intel libva-intel-driver libva-utils lib32-mesa
fi

# do yay installs
echo "${username} ALL=(ALL:ALL) NOPASSWD: $(which pacman)" >> /etc/sudoers
( su - "${username}" -c "
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --needed --noconfirm
    cd ..
    rm -rdf yay
    yay -S --needed --noconfirm brave-bin spotify neovim-nightly-bin sublime-text-4
    yay -S --needed --noconfirm hfsprogs apfsprogs-git
    yay -S --needed --noconfirm nerd-fonts-mononoki betterlockscreen
    yay -S --needed --noconfirm orchis-theme material-cursors-git
    yay -S --needed --noconfirm symfony-cli
    "
)
sed -i "\%${username} ALL=(ALL:ALL) NOPASSWD: $(which pacman)%d" /etc/sudoers

systemctl enable "betterlockscreen@${username}"

# Setup Interface
( su -l "${username}" -c "
    mkdir -p "~/.local/"

    git clone https://github.com/Sofurs/dwm.git ~/.local/dwm
    git clone https://github.com/Sofurs/dwmblocks-async.git ~/.local/dwmblocks-async

    make -C ~/.local/dwm
    make -C ~/.local/dwmblocks-async
")

make -C ~/.local/dwm install
make -C ~/.local/dwmblocks-async install

# Setup Configs
chsh -s $(which zsh) "${username}"

# udev
cp -r $system_dir/etc/udev/rules.d/* /etc/udev/rules.d/
ln -s /dev/null /etc/udev/rules.d/80-net-setup-link.rules

# xorg
cp -r $system_dir/etc/xorg/* /etc/X11/xorg.conf.d/

# bin
chmod -R +x $system_dir/bin/*
cp $system_dir/bin/* /bin

# wallpapers
cp -r $dotfile_dir/.wallpapers/ "/home/${username}/.wallpapers/"

# Setup Dotfiles
rm "/home/${username}/.bash"*

cp -r $dotfile_dir/home/.* "/home/${username}"
chown -R "${username}:${username}" "/home/${username}"

cp -r $dotfile_dir/.config/ "/home/${username}/.config/"
cp -r $dotfile_dir/.local/bin/ "/home/${username}/.local/"

curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
