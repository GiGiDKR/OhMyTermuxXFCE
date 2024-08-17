#!/bin/bash

# Installation de gum
if ! command -v gum &> /dev/null; then
    echo "Installation de gum..."
    pkg update -y
    pkg install -y gum
fi

username="$1"

# Liste des paquets nécessaires
pkgs=('git' 'virglrenderer-android' 'papirus-icon-theme' 'xfce4' 'xfce4-goodies' 'eza' 'pavucontrol-qt' 'bat' 'jq' 'nala' 'wmctrl' 'firefox' 'netcat-openbsd' 'termux-x11-nightly' 'eza')

# Installation des paquets nécessaires avec retour utilisateur
gum spin --title "Installation des paquets nécessaires" -- pkg install "${pkgs[@]}" -y -o Dpkg::Options::="--force-confold"

# Placer l'icône de Firefox sur le bureau
cp $PREFIX/share/applications/firefox.desktop $HOME/Desktop 
chmod +x $HOME/Desktop/firefox.desktop

# Définir les alias
echo "
# Aliases
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
alias md='mkdir'
alias debian='proot-distro login debian --user $username --shared-tmp'
#alias zrun='proot-distro login debian --user $username --shared-tmp -- env DISPLAY=:1.0 MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform '
#alias zrunhud='proot-distro login debian --user $username --shared-tmp -- env DISPLAY=:1.0 MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform GALLIUM_HUD=fps '
alias hud='GALLIUM_HUD=fps '
alias cat='bat '
alias apt='nala '
alias install='nala install -y '
alias uninstall='nala remove -y '
alias update='nala update'
alias upgrade='nala upgrade -y'
alias search='nala search '
alias list='nala list --upgradeable'
alias show='nala show'
" >> $PREFIX/etc/bash.bashrc

# Téléchargement de l'image de fond
gum spin --title "Téléchargement du fond d'écran" -- wget https://raw.githubusercontent.com/GiGIDKR/Termux_XFCE/main/mac_waves.png
mv mac_waves.png $PREFIX/share/backgrounds/xfce/

# Installation du thème WhiteSur-Dark
gum spin --title "Installation du thème WhiteSur-Dark" -- wget https://github.com/vinceliuice/WhiteSur-gtk-theme/archive/refs/tags/2024-05-01.zip
unzip 2024-05-01.zip
tar -xf WhiteSur-gtk-theme-2024-05-01/release/WhiteSur-Dark.tar.xz
mv WhiteSur-Dark/ $PREFIX/share/themes/
rm -rf WhiteSur*
rm 2024-05-01.zip

# Installation du thème d'icônes Fluent Cursor
gum spin --title "Installation du thème Fluent Cursor" -- wget https://github.com/vinceliuice/Fluent-icon-theme/archive/refs/tags/2024-02-25.zip
unzip 2024-02-25.zip
mv Fluent-icon-theme-2024-02-25/cursors/dist $PREFIX/share/icons/
mv Fluent-icon-theme-2024-02-25/cursors/dist-dark $PREFIX/share/icons/
rm -rf $HOME/Fluent*
rm 2024-02-25.zip

# Configuration
gum spin --title "Installation des fichiers de configuration" -- wget https://github.com/GiGIDKR/OhMyTermuxXFCE/raw/main/config.zip
unzip config.zip
rm config.zip

# Téléchargement de la police
gum spin --title "Téléchargement de la police par défaut" -- wget https://github.com/GiGIDKR/OhMyTermuxXFCE/raw/main/font.ttf
mv font.ttf .termux/font.ttf
