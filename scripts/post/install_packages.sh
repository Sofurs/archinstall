#!/bin/bash

pacman -S --needed --noconfirm xorg xorg-server xorg-xinit picom
pacman -S --needed --noconfirm man-db man-pages
pacman -S --needed --noconfirm zsh alacritty putty
pacman -S --needed --noconfirm mc ranger nautilus rofi
pacman -S --needed --noconfirm vi vim code
pacman -S --needed --noconfirm lshw htop usbutils
pacman -S --needed --noconfirm fd ripgrep
pacman -S --needed --noconfirm net-tools inetutils bind traceroute nmap nm-connection-editor
pacman -S --needed --noconfirm alsa-utils pavucontrol pamixer pulseaudio pulseaudio-alsa
pacman -S --needed --noconfirm gimp feh maim xclip qiv imagemagick
pacman -S --needed --noconfirm chromium firefox thunderbird libreoffice-fresh
pacman -S --needed --noconfirm networkmanager-l2tp networkmanager-openvpn networkmanager-openconnect
pacman -S --needed --noconfirm remmina libvncserver spice-gtk freerdp
pacman -S --needed --noconfirm vlc mpv ffmpeg obs-studio
pacman -S --needed --noconfirm font-manager terminus-font ttf-dejavu ttf-droid ttf-fira-mono ttf-fira-code ttf-opensans ttf-joypixels
pacman -S --needed --noconfirm okular zathura mupdf simple-scan xsane

pacman -S --needed --noconfirm flac wavpack a522dec libmad lame opus opencore-amr speex libmpcdec
pacman -S --needed --noconfirm dav1d rav1e libdv x265 x264 libmpeg2 xvidcore libtheora libvpx
pacman -S --needed --noconfirm jasper libwebp libavif libheif

pacman -S --needed --noconfirm file-roller tar binutils bzip2 gzip lz4 lrzip xz zip unzip unrar p7zip

pacman -S --needed --noconfirm util-linux gptfdisk parted gpart testdisk
pacman -S --needed --noconfirm btrfs-progs dosfstools exfatprogs e2fsprogs ntfs-3g

pacman -S --needed --noconfirm php7
pacman -S --needed --noconfirm jq dbeaver gnupg scrypt
pacman -S --needed --noconfirm bc gnome-calculator arandr
pacman -S --needed --noconfirm cups cups-pdf system-config-printer

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
    yay -S --needed --noconfirm nerd-fonts-dejavu-complete
    yay -S --needed --noconfirm symfony-cli
    "
)
sed -i "\%${username} ALL=(ALL:ALL) NOPASSWD: $(which pacman)%d" /etc/sudoers
