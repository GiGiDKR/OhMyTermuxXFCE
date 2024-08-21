#!/bin/bash

clear

echo "Changer le répertoire de sources Termux ? (o/n)"
read change_repo_choice

if [ "$change_repo_choice" = "o" ]; then
    termux-change-repo
fi

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
            "OHMYTERMUX" \
            "XFCE"
    else
        echo "OHMYTERMUX - XFCE"
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

clear

check_and_install_gum

show_banner

# Vérification et création du fichier colors.properties si nécessaire
termux_dir="$HOME/.termux"
file_path="$termux_dir/colors.properties"

if [ ! -f "$file_path" ]; then
    mkdir -p "$termux_dir"
    cat <<EOL > "$file_path"
## Name: TokyoNight

# Special
foreground = #c0caf5
background = #1a1b26
cursor = #c0caf5
# Black/Grey
color0 = #15161e
color8 = #414868
# Red
color1 = #f7768e
color9 = #f7768e
# Green
color2 = #9ece6a
color10 = #9ece6a
# Yellow
color3 = #e0af68
color11 = #e0af68
# Blue
color4 = #7aa2f7
color12 = #7aa2f7
# Magenta
color5 = #bb9af7
color13 = #bb9af7
# Cyan
color6 = #7dcfff
color14 = #7dcfff
# White/Grey
color7 = #a9b1d6
color15 = #c0caf5
# Other
color16 = #ff9e64
color17 = #db4b4b
EOL
fi

# Configuration du fichier termux.properties
file_path="$HOME/.termux/termux.properties"

mkdir -p "$(dirname "$file_path")"

if [ ! -f "$file_path" ]; then
    echo "Le fichier $file_path n'existe pas. Création du fichier avec le contenu par défaut."
    cat <<EOL > "$file_path"
allow-external-apps = true
use-black-ui = true
bell-character = ignore
fullscreen = true
EOL
else
    sed -i 's/^#\(allow-external-apps = true\)/\1/' "$file_path"
    sed -i 's/^#\(use-black-ui = true\)/\1/' "$file_path"
    sed -i 's/^#\(bell-character = ignore\)/\1/' "$file_path"
    sed -i 's/^#\(fullscreen = true\)/\1/' "$file_path"
fi

# Suppression du fichier motd
MOTD_PATH="/data/data/com.termux/files/usr/etc/motd"
MOTD_BACKUP_PATH="/data/data/com.termux/files/usr/etc/motd.bak"

if [ -f "$MOTD_PATH" ]; then
    mv "$MOTD_PATH" "$MOTD_BACKUP_PATH"
else
    echo "Le fichier motd n'existe pas !"
fi

# Accorder l'accès au stockage externe
show_banner
if $USE_GUM; then
    gum confirm "Accorder l'accès au stockage externe ?" && termux-setup-storage
else
    echo "Accorder l'accès au stockage externe ? (o/n)"
    read choice
    [ "$choice" = "o" ] && termux-setup-storage
fi

# Menu pour choisir le shell
show_banner
if $USE_GUM; then
    shell_choice=$(gum choose --header="Choisissez le shell à installer :" "bash" "zsh" "fish")
else
    echo "Choisissez le shell à installer :"
    echo "1) bash"
    echo "2) zsh"
    echo "3) fish"
    read -p "Entrez le numéro de votre choix : " choice
    case $choice in
        1) shell_choice="bash" ;;
        2) shell_choice="zsh" ;;
        3) shell_choice="fish" ;;
        *) shell_choice="bash" ;;
    esac
fi

case $shell_choice in
    "bash")
        echo "Bash sélectionné, poursuite du script..."
        ;;
    "zsh")
        echo "ZSH sélectionné. Installation de ZSH..."
        gum spin --title "Installation de ZSH..." -- pkg install -y zsh

        # Menu interactif pour installer Oh My Zsh
        show_banner
        if gum confirm "Voulez-vous installer Oh My Zsh ?"; then
            gum spin --title "Installation des prérequis..." -- pkg install -y wget curl git unzip
            gum spin --title "Installation de Oh My Zsh..." -- git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
            cp "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" "$HOME/.zshrc"
        fi

        # Menu interactif pour installer PowerLevel10k
        show_banner
        if gum confirm "Voulez-vous installer PowerLevel10k ?"; then
            gum spin --title "Installation de PowerLevel10k..." -- git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" || true
            echo 'source ~/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme' >> "$HOME/.zshrc"

            show_banner
            if gum confirm "Installer le prompt OhMyTermux ?"; then
                gum spin --title "Téléchargement de la configuration PowerLevel10k..." -- curl -fLo "$HOME/.p10k.zsh" https://raw.githubusercontent.com/GiGiDKR/OhMyTermuxXFCE/main/files/p10k.zsh
            else
                echo "Vous pouvez configurer le prompt PowerLevel10k manuellement en exécutant 'p10k configure' après l'installation."
            fi

            # Installation des plugins
            show_banner
            PLUGINS=$(gum choose --no-limit --header="Sélectionner avec espace les plugins à installer :" "zsh-autosuggestions" "zsh-syntax-highlighting" "zsh-completions" "you-should-use" "zsh-abbr" "zsh-alias-finder" "Tout installer")
            echo "Installation des plugins sélectionnés..."
            if [[ "$PLUGINS" == *"Tout installer"* ]]; then
                PLUGINS="zsh-autosuggestions zsh-syntax-highlighting zsh-completions you-should-use zsh-abbr zsh-alias-finder"
            fi
            for PLUGIN in $PLUGINS; do
                case $PLUGIN in
                    "zsh-autosuggestions")
                        git clone https://github.com/zsh-users/zsh-autosuggestions.git "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" || true
                        ;;
                    "zsh-syntax-highlighting")
                        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" || true
                        ;;
                    "zsh-completions")
                        git clone https://github.com/zsh-users/zsh-completions.git "$HOME/.oh-my-zsh/custom/plugins/zsh-completions" || true
                        ;;
                    "you-should-use")
                        git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "$HOME/.oh-my-zsh/custom/plugins/you-should-use" || true
                        ;;
                    "zsh-abbr")
                        git clone https://github.com/olets/zsh-abbr "$HOME/.oh-my-zsh/custom/plugins/zsh-abbr" || true
                        ;;
                    "zsh-alias-finder")
                        git clone https://github.com/akash329d/zsh-alias-finder "$HOME/.oh-my-zsh/custom/plugins/zsh-alias-finder" || true
                        ;;
                esac
            done
        fi

        # Télécharger les fichiers de configuration depuis le dépôt GitHub
        echo "Téléchargement des fichiers de configuration..."
        gum spin --title "Téléchargement des fichiers de configuration..." -- curl -fLo "$HOME/.oh-my-zsh/custom/aliases.zsh" https://raw.githubusercontent.com/GiGiDKR/OhMyTermuxXFCE/main/files/aliases.zsh
        gum spin --title "Téléchargement du fichier zshrc..." -- curl -fLo "$HOME/.zshrc" https://raw.githubusercontent.com/GiGiDKR/OhMyTermuxXFCE/main/files/zshrc

        echo "alias help='glow \$HOME/.config/OhMyTermux/Help.md'" >> "$HOME/.zshrc"

        termux-reload-settings

        chsh -s zsh
        ;;
    "fish")
        echo "Fish sélectionné. Installation de Fish..."
        pkg install -y fish

        termux-reload-settings
        chsh -s fish
        
        # TODO : ajouter la configuration de Fish, de ses plugins et des alias (abbr)
        ;;
esac

# Définir les répertoires
TERMUX=$HOME/.termux
CONFIG=$HOME/.config
COLORS_DIR_TERMUXSTYLE=$HOME/.termux/colors/termuxstyle
COLORS_DIR_TERMUX=$HOME/.termux/colors/termux
COLORS_DIR_XFCE4TERMINAL=$HOME/.termux/colors/xfce4terminal

# Créer les répertoires
mkdir -p $TERMUX $CONFIG $COLORS_DIR_TERMUXSTYLE $COLORS_DIR_TERMUX $COLORS_DIR_XFCE4TERMINAL

# Télécharger et extraire les fichiers nécessaires depuis le dépôt GitHub
show_banner
gum spin --title "Téléchargement de la police par défaut..." -- curl -L -o $HOME/.termux/font.ttf https://github.com/GiGiDKR/OhMyTermuxXFCE/raw/main/files/font.ttf

show_banner
gum spin --title "Téléchargement de l'archive Color Scheme..." -- curl -L -o $HOME/.termux/colors.zip https://github.com/GiGiDKR/OhMyTermuxXFCE/raw/main/files/colors.zip
clear
show_banner
gum spin --title "Décompression de l'archive Color Scheme..." -- unzip -o "$HOME/.termux/colors.zip" -d "$HOME/.termux/"
rm "$HOME/.termux/colors.zip"

# Menu interactif pour sélectionner une police à installer
show_banner
FONT=$(gum choose --header="Sélectionner la police à installer :" "Police par défaut" "CaskaydiaCove Nerd Font" "FiraMono Nerd Font" "JetBrainsMono Nerd Font" "Mononoki Nerd Font" "VictorMono Nerd Font" "RobotoMono Nerd Font" "DejaVuSansMono Nerd Font" "UbuntuMono Nerd Font" "AnonymousPro Nerd Font" "Terminus Nerd Font")
echo "Installation de la police sélectionnée..."
case $FONT in
    "CaskaydiaCove Nerd Font")
        install_font "https://github.com/mayTermux/myTermux/raw/main/.fonts/CaskaydiaCoveNerdFont-Regular.ttf"
        ;;
    "FiraMono Nerd Font")
        install_font "https://github.com/mayTermux/myTermux/raw/main/.fonts/FiraMono-Regular.ttf"
        ;;
    "JetBrainsMono Nerd Font")
        install_font "https://github.com/mayTermux/myTermux/raw/main/.fonts/JetBrainsMono-Regular.ttf"
        ;;
    "Mononoki Nerd Font")
        install_font "https://github.com/mayTermux/myTermux/raw/main/.fonts/Mononoki-Regular.ttf"
        ;;
    "VictorMono Nerd Font")
        install_font "https://github.com/mayTermux/myTermux/raw/main/.fonts/VictorMono-Regular.ttf"
        ;;
    "RobotoMono Nerd Font")
        install_font "https://github.com/adi1090x/termux-style/raw/master/fonts/RobotoMonoNerdFont.ttf"
        ;;
    "DejaVuSansMono Nerd Font")
        install_font "https://github.com/adi1090x/termux-style/raw/master/fonts/DejaVuSansMonoNerdFont.ttf"
        ;;
    "UbuntuMono Nerd Font")
        install_font "https://github.com/adi1090x/termux-style/raw/master/fonts/UbuntuMonoNerdFont.ttf"
        ;;
    "AnonymousPro Nerd Font")
        install_font "https://github.com/adi1090x/termux-style/raw/master/fonts/AnonymousProNerdFont.ttf"
        ;;
    "Terminus Nerd Font")
        install_font "https://github.com/adi1090x/termux-style/raw/master/fonts/TerminusNerdFont.ttf"
        ;;
esac

# Menu interactif pour sélectionner les packages à installer
show_banner
PACKAGES=$(gum choose --no-limit --height=20 --header="Sélectionner avec espace les packages à installer :" "nala" "eza" "bat" "lf" "fzf" "glow" "python" "lsd" "micro" "tsu" "Tout installer")
echo "Installation des packages sélectionnés..."
if [[ "$PACKAGES" == *"Tout installer"* ]]; then
    PACKAGES="nala eza bat lf fzf glow python lsd micro tsu"
fi
if [ -n "$PACKAGES" ]; then
    for PACKAGE in $PACKAGES; do
        gum spin --title "Installation de $PACKAGE..." -- pkg install -y $PACKAGE
    done
else
    echo "Aucun package sélectionné. Poursuite du script ..."
fi

# Confirmation pour installer OhMyTermuxXFCE
show_banner
if $USE_GUM; then
    if ! gum confirm "Installer OhMyTermuxXFCE ?"; then
        show_banner
        # Ajout du menu pour exécuter Oh-My-Termux
        if gum confirm "Exécuter OhMyTermux ?"; then
            exec $shell_choice
        else
            echo "OhMyTermux sera actif au prochain démarrage de Termux."
        fi
        exit 0
    fi
else
    echo "Installer OhMyTermuxXFCE ? (o/n)"
    read choice
    if [ "$choice" != "o" ]; then
        show_banner
        echo "Exécuter OhMyTermux ? (o/n)"
        read choice
        if [ "$choice" = "o" ]; then
            exec $shell_choice
        else
            echo "OhMyTermux sera actif au prochain démarrage de Termux."
        fi
        exit 0
    fi
fi

# Continuer le script tel qu'il est
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
echo "Création des répertoires utilisateur..."
mkdir -p $HOME/Desktop
# TODO Ajouter symlink

show_banner
if $USE_GUM; then
    gum spin --title "Téléchargement des scripts" -- wget https://github.com/GiGiDKR/OhMyTermuxXFCE/raw/main/xfce.sh
    gum spin --title "Téléchargement des scripts" -- wget https://github.com/GiGiDKR/OhMyTermuxXFCE/raw/main/proot.sh
    gum spin --title "Téléchargement des scripts" -- wget https://github.com/GiGiDKR/OhMyTermuxXFCE/raw/main/utils.sh
else
    clear && echo "Téléchargement des scripts..."
    wget https://github.com/GiGiDKR/OhMyTermuxXFCE/raw/main/xfce.sh
    wget https://github.com/GiGiDKR/OhMyTermuxXFCE/raw/main/proot.sh
    wget https://github.com/GiGiDKR/OhMyTermuxXFCE/raw/main/utils.sh
fi

chmod +x *.sh

show_banner
./xfce.sh "$username" --gum
./proot.sh "$username" --gum
./utils.sh

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

rm xfce.sh
rm proot.sh
rm utils.sh
rm install.sh

show_banner
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
    echo "XFCE4 (GUI) : start"
    echo "DEBIAN (CLI) : debian"
    echo
fi

# Ajout du menu pour exécuter Oh-My-Termux
show_banner
if $USE_GUM; then
    if gum confirm "Exécuter OhMyTermux ?"; then
        exec $shell_choice
    else
        show_banner
        echo "OhMyTermux sera actif au prochain démarrage de Termux."
    fi
else
    echo "Exécuter OhMyTermux ? (o/n)"
    read choice
    if [ "$choice" = "o" ]; then
        clear
        exec $shell_choice
    else
        show_banner
        echo "OhMyTermux sera actif au prochain démarrage de Termux."
    fi
fi