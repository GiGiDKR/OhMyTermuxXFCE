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

banner() {
    gum style --border double --padding "1 2" --margin "1 2" --align center --foreground 212 --background 57 "OhMyTermuxXFCE"
}

finish() {
  local ret=$?
  if [ ${ret} -ne 0 ] && [ ${ret} -ne 130 ]; then
    echo
    gum style --foreground 196 "ERREUR: Installation de XFCE dans Termux impossible."
    echo "Veuillez vous référer au(x) message(s) d'erreur ci-dessus."
  fi
}

trap finish EXIT

clear

banner

# Vérification et création du fichier colors.properties si nécessaire
termux_dir="$HOME/.termux"
file_path="$termux_dir/colors.properties"

if [ ! -f "$file_path" ]; then
    echo "Création du fichier colors.properties avec le contenu par défaut..."
    mkdir -p "$termux_dir"
    cat <<EOL > "$file_path"
# http://dotfiles.org/~jbromley/.Xresources
background=#000010
foreground=#ffffff
cursor=#FF00FF

color0=#000000
color1=#9e1828
color2=#aece92
color3=#968a38
color4=#414171
color5=#963c59
color6=#418179
color7=#bebebe
color8=#666666
color9=#cf6171
color10=#c5f779
color11=#fff796
color12=#4186be
color13=#cf9ebe
color14=#71bebe
color15=#ffffff
EOL
fi

echo ""
username=$(gum input --placeholder "Entrez le nom d'utilisateur à créer : " --password)
clear

gum spin --title "Mise à jour des dépôts" -- termux-change-repo

gum spin --title "Mise à jour des paquets" -- pkg update -y -o Dpkg::Options::="--force-confold"
gum spin --title "Mise à niveau des paquets" -- pkg upgrade -y -o Dpkg::Options::="--force-confold"

file_path="$HOME/.termux/termux.properties"

if [ ! -f "$file_path" ]; then
  echo "Le fichier $file_path n'existe pas."
fi
sed -i 's/^#\(allow-external-apps = true\)/\1/' "$file_path"
sed -i 's/^#\(use-black-ui = true\)/\1/' "$file_path"
sed -i 's/^#\(bell-character = ignore\)/\1/' "$file_path"
sed -i 's/^#\(fullscreen = true\)/\1/' "$file_path"

if [ -f "/data/user/0/com.termux/files/usr/etc/motd" ];then
    mv /data/user/0/com.termux/files/usr/etc/motd /data/user/0/com.termux/files/usr/etc/motd.bak;
else
    echo "Le fichier motd n'existe pas !"
fi

clear -x
banner
echo ""
echo "Configuration de l'accès au stockage externe." 
echo ""
gum confirm "Appuyez sur n'importe quelle touche pour continuer..." && termux-setup-storage
clear

pkgs=('wget' 'ncurses-utils' 'dbus' 'proot-distro' 'x11-repo' 'tur-repo' 'pulseaudio')

gum spin --title "Installation de ncurses-ui-libs" -- pkg install ncurses-ui-libs

gum spin --title "Désinstallation de dbus" -- pkg uninstall dbus -y
gum spin --title "Mise à jour des paquets" -- pkg update
gum spin --title "Installation des paquets nécessaires" -- pkg install "${pkgs[@]}" -y -o Dpkg::Options::="--force-confold"

clear -x
banner
echo ""
echo "Création des répertoires utilisateur..."
mkdir $HOME/Desktop

gum spin --title "Téléchargement des scripts" -- wget https://github.com/GiGiDKR/OhMyTermuxXFCE/raw/main/xfce_gum.sh
gum spin --title "Téléchargement des scripts" -- wget https://github.com/GiGiDKR/OhMyTermuxXFCE/raw/main/proot_gum.h
gum spin --title "Téléchargement des scripts" -- wget https://github.com/GiGiDKR/OhMyTermuxXFCE/raw/main/utils.sh

chmod +x *.sh

gum spin --title "Exécution du script xfce" -- ./xfce_gum.sh "$username"
gum spin --title "Exécution du script proot" -- ./proot_gum.sh "$username"
gum spin --title "Exécution du script utils" -- ./utils.sh

clear -x
echo ""
echo "Installation de Termux-X11 APK" 
echo ""
if gum confirm "Voulez-vous installer Termux-X11 ?"; then
    gum spin --title "Téléchargement de Termux-X11 APK" -- wget https://github.com/termux/termux-x11/releases/download/nightly/app-arm64-v8a-debug.apk
    mv app-arm64-v8a-debug.apk $HOME/storage/downloads/
    termux-open $HOME/storage/downloads/app-arm64-v8a-debug.apk
    rm $HOME/storage/downloads/app-arm64-v8a-debug.apk
fi

source $PREFIX/etc/bash.bashrc
termux-reload-settings

rm xfce_v2.sh
rm proot_v2.sh
rm utils.sh
rm install_v2.sh

clear -x
banner
echo ""
echo "Installation terminée !"
echo ""
echo "Pour lancer XFCE4, saisissez : start"
echo "Pour accéder à DEBIAN saisissez : debian"
echo ""
gum style --border double --padding "1 2" --margin "1 2" --align center --foreground 212 --border-foreground=212 --width 40 "Installation terminée !"
