#!/bin/zsh

# Unofficial Zsh Strict Mode
set -euo pipefail
IFS=$'\n\t'

banner() {
    cat << 'EOF'

████████╗███████╗██████╗ ███╗   ███╗██╗   ██╗██╗  ██╗ 
╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║   ██║╚██╗██╔╝ 
   ██║   █████╗  ██████╔╝██╔████╔██║██║   ██║ ╚███╔╝  
   ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║   ██║ ██╔██╗  
   ██║   ███████╗██║  ██║██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗ 
   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝ 
█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗
╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝
           ██╗  ██╗███████╗ ██████╗███████╗           
           ╚██╗██╔╝██╔════╝██╔════╝██╔════╝           
            ╚███╔╝ █████╗  ██║     █████╗             
            ██╔██╗ ██╔══╝  ██║     ██╔══╝             
           ██╔╝ ██╗██║     ╚██████╗███████╗           
           ╚═╝  ╚═╝╚═╝      ╚═════╝╚══════╝           
           ███████╗███████╗███████╗███████╗           
           ╚══════╝╚══════╝╚══════╝╚══════╝           
EOF
}

finish() {
  local ret=$?
  if [ ${ret} -ne 0 ] && [ ${ret} -ne 130 ]; then
    echo
    echo "  ERREUR: Installation de XFCE dans Termux impossible."
    echo "  Veuillez vous référer au(x) message(s) d'erreur ci-dessus."
  fi
}

trap finish EXIT

clear

banner

echo ""
echo "  Installation de XFCE Termux avec une racine Debian."
echo ""
read -r -p "  Entrez le nom d'utilisateur à créer : " username </dev/tty
clear

termux-change-repo
pkg update -y -o Dpkg::Options::="--force-confold"
pkg upgrade -y -o Dpkg::Options::="--force-confold"


if [ -f "/data/user/0/com.termux/files/usr/etc/motd" ]; then
  mv /data/user/0/com.termux/files/usr/etc/motd /data/user/0/com.termux/files/usr/etc/motd.bak
else
  echo "  Le fichier motd n'existe pas !"
fi

clear -x
banner
echo ""
echo "  Configuration de l'accès au stockage externe." 
echo ""
read -n 1 -s -r -p "  Appuyez sur n'importe quelle touche pour continuer..."
termux-setup-storage
clear

pkgs=('wget' 'ncurses-utils' 'dbus' 'proot-distro' 'x11-repo' 'tur-repo' 'pulseaudio')

pkg install ncurses-ui-libs

pkg uninstall dbus -y
pkg update
pkg install "${pkgs[@]}" -y -o Dpkg::Options::="--force-confold"

clear -x
banner
echo ""
echo "  Création des répertoires utilisateur..."
mkdir $HOME/Desktop

wget https://github.com/GiGiDKR/Termux_XFCE/raw/main/xfce_zsh.sh
wget https://github.com/GiGiDKR/Termux_XFCE/raw/main/proot_zsh.sh
wget https://github.com/GiGiDKR/Termux_XFCE/raw/main/utils_zsh.sh

chmod +x *.sh

./xfce_zsh.sh "$username"
./proot_zsh.sh "$username"
./utils_zsh.sh

clear -x
echo ""
echo "Installation de Termux-X11 APK" 
echo ""
read -n 1 -s -r -p "  Voulez-vous installer Termux-X11 ? (o/n) " termux_x11
if [[ $termux_x11 =~ ^[Oo]$ ]]; then
  wget https://github.com/termux/termux-x11/releases/download/nightly/app-arm64-v8a-debug.apk
  mv app-arm64-v8a-debug.apk $HOME/storage/downloads/
  termux-open $HOME/storage/downloads/app-arm64-v8a-debug.apk
  rm $HOME/storage/downloads/app-arm64-v8a-debug.apk
fi

source $PREFIX/etc/zshrc
termux-reload-settings

rm xfce_zsh.sh
rm proo_zsh.sh
rm utils_zsh.sh
rm install_zsh.sh

clear -x
banner
echo ""
echo "                  Installation terminée !              "
echo ""
echo "  Pour lancer XFCE4, saisissez :                  start"
echo "  Pour accéder à DEBIAN saisissez :              debian"
echo ""
echo "  Changer le thème Termux : sh Scripts/themeselector.sh"
echo "  Pour installer oh-my-zsh :      sh Scripts/ohmyzsh.sh"
echo "  Pour installer oh-my-posh :    sh Scripts/ohmyposh.sh"
echo ""
echo "  Pour installer Electron :      sh Scripts/electron.sh"
echo "  Pour PowerShell :      sh Scripts/powershell.sh"
echo ""
echo "  Pour xRDP Termux :    sh Scripts/xrdp-setup-termux.sh"
echo "  Pour xRDP Debian :           sh Scripts/xrdp-setup.sh"
echo ""
echo " █████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗"
echo " ╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝"
echo ""