#!/bin/bash

# Unofficial Bash Strict Mode
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
    echo "  Veuillez vous referer au(x) message(s) d'erreur ci dessus."
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

sed -i '21s/^#//' $HOME/.termux/termux.properties
sed -i '80s/^#//' $HOME/.termux/termux.properties
sed -i '81s/^#//' $HOME/.termux/termux.properties
sed -i '128s/^#//' $HOME/.termux/termux.properties
sed -i '160s/^#//' $HOME/.termux/termux.properties

echo "
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

" > $HOME/.termux/colors.properties

if [ -f "/data/user/0/com.termux/files/usr/etc/motd" ];then
mv /data/user/0/com.termux/files/usr/etc/motd /data/user/0/com.termux/files/usr/etc/motd.bak;
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
mkdir $HOME/Downloads
mkdir $HOMES/Scripts
mkdir $HOME/Pictures
mkdir $HOME/Videos
ln -s $HOME/storage/music Music 
ln -s $HOME/storage/documents Documents 


wget https://github.com/GiGiDKR/Termux_XFCE/raw/main/xfce.sh
wget https://github.com/GiGiDKR/Termux_XFCE/raw/main/proot.sh
wget https://github.com/GiGiDKR/Termux_XFCE/raw/main/utils.sh
wget https://github.com/GiGiDKR/Termux_XFCE/raw/main/scripts/themeselector.sh && mv themeselector.sh $HOME/Scripts
wget https://github.com/GiGiDKR/Termux_XFCE/raw/main/scripts/electron.sh && mv electron.sh $HOME/Scripts
wget https://github.com/GiGiDKR/Termux_XFCE/raw/main/scripts/ohmyzsh.sh && mv ohmyzsh.sh $HOME/Scripts
wget https://github.com/GiGiDKR/Termux_XFCE/raw/main/scripts/ohmyposh.sh && mv ohmyposh.sh $HOME/Scripts
wget https://github.com/GiGiDKR/Termux_XFCE/raw/main/scripts/xrdp-setup.sh && mv xrdp-setup.sh $HOME/Scripts
wget https://github.com/GiGiDKR/Termux_XFCE/raw/main/scripts/xrdp-setup-termux.sh && mv xrdp-setup-termux.sh $HOME/Scripts

chmod +x *.sh
chmod +x $HOME/Scripts/*.sh

./xfce.sh "$username"
./proot.sh "$username"
./utils.sh

clear -x
echo ""
echo "Installation de Termux-X11 APK" 
echo ""
read -n 1 -s -r -p "  Voulez-vous installer Termux-X11 ? (o/n) " termux_x11
if [[ $termux_x11 =~ ^[Oo]$ ]]; then
	wget https://github.com/termux/termux-x11/releases/download/nightly/app-arm64-v8a-debug.apk
    mv app-arm64-v8a-debug.apk $HOME/storage/downloads/
    termux-open $HOME/storage/downloads/app-arm64-v8a-debug.apk
fi

source $PREFIX/etc/bash.bashrc
termux-reload-settings

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
echo ""
echo "  Pour xRDP Termux :    sh Scripts/xrdp-setup-termux.sh"
echo "  Pour xRDP Debian :           sh Scripts/xrdp-setup.sh"
echo ""
echo " █████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗"
echo " ╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝"
echo ""

rm $HOME/storage/downloads/app-arm64-v8a-debug.apk
rm xfce.sh
rm proot.sh
rm utils.sh
rm install.sh
