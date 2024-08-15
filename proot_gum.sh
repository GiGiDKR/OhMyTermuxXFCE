#!/bin/bash

# Unofficial Bash Strict Mode
set -euo pipefail
IFS=$'\n\t'

# Installation de gum
if ! command -v gum &> /dev/null; then
    echo "Installation de gum..."
    pkg update -y
    pkg install -y gum
fi

finish() {
  local ret=$?
  if [ ${ret} -ne 0 ] && [ ${ret} -ne 130 ]; then
    echo
    gum style --foreground 196 "ERREUR: Failed to setup XFCE on Termux."
    echo "Please refer to the error message(s) above"
  fi
}

trap finish EXIT

username="$1"

pkgs_proot=('sudo' 'wget' 'nala' 'jq')

# Installation de Debian proot avec gum spin pour le retour utilisateur
gum spin --title "Installation de Debian proot" -- pd install debian

# Mise à jour des paquets avec gum spin
gum spin --title "Mise à jour des paquets" -- pd login debian --shared-tmp -- env DISPLAY=:1.0 apt update
pd login debian --shared-tmp -- env DISPLAY=:1.0 apt upgrade -y

gum spin --title "Installation des paquets" -- pd login debian --shared-tmp -- env DISPLAY=:1.0 apt install "${pkgs_proot[@]}" -y -o Dpkg::Options::="--force-confold"

# Création de l'utilisateur avec gum spin
gum spin --title "Création de l'utilisateur" -- {
    pd login debian --shared-tmp -- env DISPLAY=:1.0 groupadd storage
    pd login debian --shared-tmp -- env DISPLAY=:1.0 groupadd wheel
    pd login debian --shared-tmp -- env DISPLAY=:1.0 useradd -m -g users -G wheel,audio,video,storage -s /bin/bash "$username"
}

# Ajout de l'utilisateur à sudoers
gum spin --title "Ajout à sudoers" -- {
    chmod u+rw $PREFIX/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers
    echo "$username ALL=(ALL) NOPASSWD:ALL" | tee -a $PREFIX/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers > /dev/null
    chmod u-w $PREFIX/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers
}

# Configuration de l'affichage proot
echo "export DISPLAY=:1.0" >> $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.bashrc

# Configuration des alias proot
echo "
alias zink='MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform '
alias hud='GALLIUM_HUD=fps '
alias l='eza -1 --icons'
alias ls='eza --icons'
alias ll='eza -lF -a --icons --total-size --no-permissions --no-time --no-user'
alias la='eza --icons -lgha --group-directories-first'
alias lt='eza --icons --tree'
alias lta='eza --icons --tree -lgha'
alias dir='eza -lF --icons'
alias ..='cd ..'
alias q='exit'
alias c='clear'
alias cat='bat '
alias apt='sudo nala '
alias install='sudo nala install -y '
alias update='sudo nala update'
alias upgrade='sudo nala upgrade -y'
alias remove='sudo nala remove -y '
alias list='nala list --upgradeable'
alias show='nala show '
alias search='nala search '
alias start='echo please run from termux, not Debian proot.'
" >> $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.bashrc

# Configuration du fuseau horaire proot
timezone=$(getprop persist.sys.timezone)
pd login debian --shared-tmp -- env DISPLAY=:1.0 rm /etc/localtime
pd login debian --shared-tmp -- env DISPLAY=:1.0 cp /usr/share/zoneinfo/$timezone /etc/localtime

# Application du thème de xfce à proot
cd $PREFIX/share/icons
find dist-dark | cpio -pdm $PREFIX/var/lib/proot-distro/installed-rootfs/debian/usr/share/icons

cat <<'EOF' > $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.Xresources
Xcursor.theme: dist-dark
EOF

mkdir -p $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.fonts/
mkdir -p $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.themes/

# Configuration de l'accélération matérielle
gum spin --title "Téléchargement de mesa-vulkan-kgsl" -- pd login debian --shared-tmp -- env DISPLAY=:1.0 wget https://github.com/GiGIDKR/Termux_XFCE/raw/main/mesa-vulkan-kgsl_24.1.0-devel-20240120_arm64.deb
pd login debian --shared-tmp -- env DISPLAY=:1.0 sudo apt install -y ./mesa-vulkan-kgsl_24.1.0-devel-20240120_arm64.deb
