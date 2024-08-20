#!/bin/bash

# Variable pour déterminer si gum doit être utilisé
USE_GUM=false

# Vérification des arguments
for arg in "$@"; do
    case $arg in
        --gum|-g)
            USE_GUM=true
            shift
            ;;
    esac
done

# Fonction pour vérifier et installer gum
check_and_install_gum() {
    if $USE_GUM && ! command -v gum &> /dev/null; then
        echo "Installation de gum..."
        pkg update -y && pkg install gum -y
    fi
}

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
            "Oh-My-Termux" \
            "    XFCE  "
    else
        echo "Oh-My-Termux - XFCE"
        echo ""
    fi
}

# Fonction de fin pour gérer les erreurs
finish() {
  local ret=$?
  if [ ${ret} -ne 0 ] && [ ${ret} -ne 130 ]; then
    echo
    if $USE_GUM; then
        gum style --foreground 196 "ERREUR: Installation de XFCE dans Termux impossible."
    else
        echo "ERREUR: Installation de XFCE dans Termux impossible."
    fi
    echo "Veuillez vous référer au(x) message(s) d'erreur ci-dessus."
  fi
}

trap finish EXIT

# Début du script
clear

# Appel de la fonction pour vérifier et installer gum
check_and_install_gum

# Afficher la bannière
show_banner

# Vérification et création du fichier colors.properties si nécessaire
termux_dir="$HOME/.termux"
file_path="$termux_dir/colors.properties"

if [ ! -f "$file_path" ]; then
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

show_banner
if $USE_GUM; then
    username=$(gum input --placeholder "Entrez le nom d'utilisateur à créer : ")
else
    echo "Entrez le nom d'utilisateur à créer : "
    read username
fi
clear

show_banner
if $USE_GUM; then
    gum confirm "Choisir un répertoire de sources Termux ?" && termux-change-repo
else
    echo "Choisir un répertoire de sources Termux ? (o/n)"
    read choice
    [ "$choice" = "o" ] && termux-change-repo
fi

show_banner
if $USE_GUM; then
    gum spin --title "Mise à jour des paquets" -- pkg update -y
else
    echo && echo "Mise à jour des paquets..."
    pkg update -y
fi

show_banner
if $USE_GUM; then
    gum spin --title "Mise à niveau des paquets" -- pkg upgrade -y
else
    echo && echo "Mise à niveau des paquets..."
    pkg upgrade -y
fi


file_path="$HOME/.termux/termux.properties"

# Vérifier et créer le répertoire si nécessaire
mkdir -p "$(dirname "$file_path")"

# Vérifier l'existence du fichier et le créer avec le contenu par défaut si nécessaire
if [ ! -f "$file_path" ]; then
    echo "Le fichier $file_path n'existe pas. Création du fichier avec le contenu par défaut."
    cat <<EOL > "$file_path"
allow-external-apps = true
use-black-ui = true
bell-character = ignore
fullscreen = true
EOL
else
    # Modifier le fichier pour décommenter les lignes spécifiques
    sed -i 's/^#\(allow-external-apps = true\)/\1/' "$file_path"
    sed -i 's/^#\(use-black-ui = true\)/\1/' "$file_path"
    sed -i 's/^#\(bell-character = ignore\)/\1/' "$file_path"
    sed -i 's/^#\(fullscreen = true\)/\1/' "$file_path"
fi

if [ -f "/data/user/0/com.termux/files/usr/etc/motd" ]; then
    mv /data/user/0/com.termux/files/usr/etc/motd /data/user/0/com.termux/files/usr/etc/motd.bak
else
    echo "Le fichier motd n'existe pas !"
fi

show_banner
if $USE_GUM; then
    gum confirm "Accorder l'accès au stockage externe ?" && termux-setup-storage
else
    echo "Accorder l'accès au stockage externe ? (o/n)"
    read choice
    [ "$choice" = "o" ] && termux-setup-storage
fi

show_banner
pkgs=('wget' 'ncurses-utils' 'dbus' 'proot-distro' 'x11-repo' 'tur-repo' 'pulseaudio')

show_banner
if $USE_GUM; then
    gum spin --title "Installation des pré-requis" -- pkg install ncurses-ui-libs && pkg uninstall dbus -y
else
    echo && echo "Installation des pré-requis..."
    pkg install ncurses-ui-libs && pkg uninstall dbus -y
fi

show_banner
if $USE_GUM; then
    gum spin --title "Mise à jour des paquets" -- pkg update -y
else
    echo && echo "Mise à jour des paquets..."
    pkg update -y
fi

show_banner
if $USE_GUM; then
    gum spin --title "Installation des paquets nécessaires" -- pkg install "${pkgs[@]}" -y
else
    echo && echo "Installation des paquets nécessaires..."
    pkg install "${pkgs[@]}" -y
fi

show_banner
echo ""
echo "Création des répertoires utilisateur..."
mkdir -p $HOME/Desktop
# To do : symlink

show_banner
if $USE_GUM; then
    gum spin --title "Téléchargement des scripts" -- wget https://github.com/GiGiDKR/OhMyTermuxXFCE/raw/main/xfce_gum.sh
    gum spin --title "Téléchargement des scripts" -- wget https://github.com/GiGiDKR/OhMyTermuxXFCE/raw/main/proot_gum.sh
    gum spin --title "Téléchargement des scripts" -- wget https://github.com/GiGiDKR/OhMyTermuxXFCE/raw/main/utils.sh
else
    clear && echo "Téléchargement des scripts..."
    wget https://github.com/GiGiDKR/OhMyTermuxXFCE/raw/main/xfce_gum.sh
    wget https://github.com/GiGiDKR/OhMyTermuxXFCE/raw/main/proot_gum.sh
    wget https://github.com/GiGiDKR/OhMyTermuxXFCE/raw/main/utils.sh
fi

chmod +x *.sh

show_banner
if $USE_GUM; then
    gum spin --title "Exécution du script xfce" -- ./xfce_gum.sh "$username"
    gum spin --title "Exécution du script proot" -- ./proot_gum.sh "$username"
    gum spin --title "Exécution du script utils" -- ./utils.sh
else
    echo && echo "Exécution du script xfce..."
    ./xfce_gum.sh "$username"
    echo && echo "Exécution du script proot..."
    ./proot_gum.sh "$username"
    echo && echo "Exécution du script utils..."
    ./utils.sh
fi

show_banner
echo "Installation de Termux-X11 APK"
echo ""
if $USE_GUM; then
    if gum confirm "Voulez-vous installer Termux-X11 ?"; then
        gum spin --title "Téléchargement de Termux-X11 APK" -- wget https://github.com/termux/termux-x11/releases/download/nightly/app-arm64-v8a-debug.apk
        mv app-arm64-v8a-debug.apk $HOME/storage/downloads/
        termux-open $HOME/storage/downloads/app-arm64-v8a-debug.apk
        rm $HOME/storage/downloads/app-arm64-v8a-debug.apk
    fi
else
    echo "Voulez-vous installer Termux-X11 ? (o/n)"
    read choice
    if [ "$choice" = "o" ]; then
        echo && echo "Téléchargement de Termux-X11 APK..."
        wget https://github.com/termux/termux-x11/releases/download/nightly/app-arm64-v8a-debug.apk
        mv app-arm64-v8a-debug.apk $HOME/storage/downloads/
        termux-open $HOME/storage/downloads/app-arm64-v8a-debug.apk
        rm $HOME/storage/downloads/app-arm64-v8a-debug.apk
    fi
fi

source $PREFIX/etc/bash.bashrc
termux-reload-settings

rm xfce_gum.sh
rm proot_gum.sh
rm utils.sh
rm install_gum.sh

show_banner
if $USE_GUM; then
    if $USE_GUM; then
        gum style \
            --foreground 212 \
            --border-foreground 212 \
            --align center \
            --width 40 \
            --margin "1 2" \
            "Installation terminée !" \
            "Exécuter XFCE4 : start" \
            "Exécuter DEBIAN : debian"
 else
    echo "Installation terminée !"
    echo
    echo "Exécuter XFCE4 : start"
    echo "Exécuter DEBIAN : debian"
    echo
fi
