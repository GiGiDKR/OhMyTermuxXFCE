#!/bin/bash

# Fonction pour afficher la bannière avec ou sans gum
show_banner() {
    clear
    if $USE_GUM; then
        gum style \
            --foreground 212 \
            --border-foreground 212 \
            --border double \
            --align center \
            --width 40 \
            --margin "1 2" \
            "OHMYTERMUX" \
            "XFCE"
    else
        echo "OHMYTERMUX - XFCE"
        echo ""
    fi
}

clear

# Installation de gum
show_banner
if ! command -v gum &> /dev/null; then
    echo "Installation de gum..."
    pkg update -y
    pkg install -y gum
fi

finish() {
  local ret=$?
  if [ ${ret} -ne 0 ] && [ ${ret} -ne 130 ]; then
    echo
    if command -v gum &> /dev/null; then
        gum style --foreground 196 "ERREUR: Failed to setup XFCE on Termux."
    else
        echo "ERREUR: Failed to setup XFCE on Termux."
    fi
    echo "Please refer to the error message(s) above"
  fi
}

trap finish EXIT

username="$1"

pkgs_proot=('sudo' 'wget' 'nala' 'jq')

# Vérifier si gum est installé et utiliser echo si ce n'est pas le cas
show_banner
if command -v gum &> /dev/null; then
    gum spin --title "Installation de Debian proot" -- pd install debian
else
    echo "Installation de Debian proot..."
    pd install debian
fi

# Mise à jour des paquets
show_banner
if command -v gum &> /dev/null; then
    gum spin --title "Mise à jour des paquets" -- pd login debian --shared-tmp -- env DISPLAY=:1.0 apt update
else
    echo "Mise à jour des paquets..."
    pd login debian --shared-tmp -- env DISPLAY=:1.0 apt update
fi
pd login debian --shared-tmp -- env DISPLAY=:1.0 apt upgrade -y

# Installation des paquets
show_banner
if command -v gum &> /dev/null; then
    gum spin --title "Installation des paquets" -- pd login debian --shared-tmp -- env DISPLAY=:1.0 apt install "${pkgs_proot[@]}" -y
else
    echo "Installation des paquets..."
    pd login debian --shared-tmp -- env DISPLAY=:1.0 apt install "${pkgs_proot[@]}" -y
fi

# Création de l'utilisateur
show_banner
if command -v gum &> /dev/null; then
    gum spin --title "Création de l'utilisateur" -- {
        pd login debian --shared-tmp -- env DISPLAY=:1.0 groupadd storage
        pd login debian --shared-tmp -- env DISPLAY=:1.0 groupadd wheel
        pd login debian --shared-tmp -- env DISPLAY=:1.0 useradd -m -g users -G wheel,audio,video,storage -s /bin/bash "$username"
    }
else
    echo "Création de l'utilisateur..."
    pd login debian --shared-tmp -- env DISPLAY=:1.0 groupadd storage
    pd login debian --shared-tmp -- env DISPLAY=:1.0 groupadd wheel
    pd login debian --shared-tmp -- env DISPLAY=:1.0 useradd -m -g users -G wheel,audio,video,storage -s /bin/bash "$username"
fi

# Ajout de l'utilisateur à sudoers
show_banner
if command -v gum &> /dev/null; then
    gum spin --title "Ajout à sudoers" -- {
        chmod u+rw $PREFIX/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers
        echo "$username ALL=(ALL) NOPASSWD:ALL" | tee -a $PREFIX/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers > /dev/null
        chmod u-w $PREFIX/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers
    }
else
    echo "Ajout à sudoers..."
    chmod u+rw $PREFIX/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers
    echo "$username ALL=(ALL) NOPASSWD:ALL" | tee -a $PREFIX/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers > /dev/null
    chmod u-w $PREFIX/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers
fi

# Configuration de l'affichage proot
show_banner
echo "Configuration de l'affichage proot..."
echo "export DISPLAY=:1.0" >> $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.bashrc

# Configuration des alias proot
show_banner
echo "Configuration des alias proot..."
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
alias cm='chmod +x'
alias clone='git clone'
alias push=\"git pull && git add . && git commit -m 'mobile push' && git push\"
alias bashconfig='nano $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.bashrc'
" >> $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.bashrc

# Configuration du fuseau horaire proot
show_banner
echo "Configuration du fuseau horaire proot..."
timezone=$(getprop persist.sys.timezone)
pd login debian --shared-tmp -- env DISPLAY=:1.0 rm /etc/localtime
pd login debian --shared-tmp -- env DISPLAY=:1.0 cp /usr/share/zoneinfo/$timezone /etc/localtime

# Application du thème de xfce à proot
show_banner
echo "Application du thème de xfce à proot..."
cd $PREFIX/share/icons
find dist-dark | cpio -pdm $PREFIX/var/lib/proot-distro/installed-rootfs/debian/usr/share/icons

cat <<'EOF' > $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.Xresources
Xcursor.theme: dist-dark
EOF

mkdir -p $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.fonts/
mkdir -p $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.themes/

# Configuration de l'accélération matérielle
show_banner
if command -v gum &> /dev/null; then
    gum spin --title "Téléchargement de mesa-vulkan-kgsl" -- pd login debian --shared-tmp -- env DISPLAY=:1.0 wget https://github.com/GiGIDKR/OhMyTermuxXFCE/raw/main/mesa-vulkan-kgsl_24.1.0-devel-20240120_arm64.deb
else
    echo "Téléchargement de mesa-vulkan-kgsl..."
    pd login debian --shared-tmp -- env DISPLAY=:1.0 wget https://github.com/GiGIDKR/OhMyTermuxXFCE/raw/main/mesa-vulkan-kgsl_24.1.0-devel-20240120_arm64.deb
fi
pd login debian --shared-tmp -- env DISPLAY=:1.0 sudo apt install -y ./mesa-vulkan-kgsl_24.1.0-devel-20240120_arm64.deb