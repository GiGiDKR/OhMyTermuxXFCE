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

rm /data/user/0/com.termux/files/usr/etc/motd

clear -x
banner
echo ""
echo "  Configuration de l'accès au stockage de Termux." 
echo ""
read -n 1 -s -r -p "  Appuyez sur n'importe quelle touche pour continuer..."
termux-setup-storage
clear

pkgs=('wget' 'ncurses-utils' 'dbus' 'proot-distro' 'x11-repo' 'tur-repo' 'pulseaudio')

# pkg install ncurses-ui-libs

pkg uninstall dbus -y
pkg update
pkg install "${pkgs[@]}" -y -o Dpkg::Options::="--force-confold"

mkdir -p Desktop
mkdir -p Downloads

./xfce.sh "$username"
./proot.sh "$username"
./utils.sh

clear -x
echo ""
echo "Installation de Termux-X11 APK" 
echo ""
read -n 1 -s -r -p "  Appuyez sur n'importe quelle touche pour continuer..."
wget https://github.com/termux/termux-x11/releases/download/nightly/app-arm64-v8a-debug.apk
mv app-arm64-v8a-debug.apk $HOME/storage/downloads/
termux-open $HOME/storage/downloads/app-arm64-v8a-debug.apk

source $PREFIX/etc/bash.bashrc
termux-reload-settings

clear -x
clear
banner
echo ""
echo "  Installation terminée !"
echo ""
echo "  Pour lancer XFCE4, exécutez :               start"
echo "  Pour accéder à DEBIAN exécutez :            debian"
echo ""

rm xfce.sh
rm proot.sh
rm utils.sh
rm install.sh

pkgs=('git' 'virglrenderer-android' 'papirus-icon-theme' 'xfce4' 'xfce4-goodies' 'eza' 'pavucontrol-qt' 'bat' 'jq' 'nala' 'wmctrl' 'firefox' 'netcat-openbsd' 'termux-x11-nightly' 'fish' 'micro')
pkg install "${pkgs[@]}" -y -o Dpkg::Options::="--force-confold"

# Put Firefox icon on Desktop
cp $PREFIX/share/applications/firefox.desktop $HOME/Desktop 
chmod +x $HOME/Desktop/firefox.desktop

#Set aliases
echo "
alias ls='eza -lF --icons'
alias l='eza -1 --icons'
alias la='eza -lF -a --icons'
alias ll='eza -T --icons'
alias dir='eza -lF --icons'
alias ..='cd ..'
alias q='exit'
alias c='clear'
alias md='mkdir'
alias f='fish '
alias prompt='fish -c "tide configure"'
alias alias='micro $PREFIX/etc/bash.bashrc'
alias zrun='proot-distro login debian --user $username --shared-tmp -- env DISPLAY=:1.0 MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform'
alias zrunhud='proot-distro login debian --user $username --shared-tmp -- env DISPLAY=:1.0 MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform GALLIUM_HUD=fps'
alias hud='GALLIUM_HUD=fps '
alias debian='proot-distro login debian --user $username --shared-tmp'
alias cat='bat'
alias apt='nala'
alias install='nala install -y'
alias uninstall='nala remove -y'
alias search='nala search'
alias list='nala list --upgradeable'
alias show='nala show'

" >> $PREFIX/etc/bash.bashrc

# Fish configuration in Termux
mkdir -p $HOME/.config/fish

# Added aliases in fish configuration for Termux
echo "
# Custom alias
abbr -a l 'eza -1 --icons'
abbr -a ls 'eza -lF --icons'
abbr -a la 'eza -lF -a --icons'
abbr -a ll 'eza -T --icons'
abbr -a dir 'eza -lF --icons'
abbr -a '..' 'cd ..'
abbr -a q 'exit'
abbr -a c 'clear'
abbr -a py 'python'
abbr -a pipin 'pip install --upgrade'
abbr -a n 'nano'
abbr -a s 'source'
abbr -a ex 'exec'
abbr -a f 'fish'
abbr -a b 'bash'
abbr -a md 'mkdir'
abbr -a alias 'nano $HOME/.config/fish/config.fish'
abbr -a conf 'cd ~/.config'
abbr -a '?' pwd
abbr -a ip 'ifconfig'
abbr -a termux 'micro ~/.termux/termux.properties'
abbr -a venv 'source ./venv/bin/activate.fish'
abbr -a cat 'bat'
abbr -a apt 'nala'
abbr -a update 'nala update'
abbr -a upgrade 'nala upgrade -y'
abbr -a install 'nala install -y'
abbr -a uninstall 'nala remove -y'
abbr -a search 'nala search'
abbr -a list 'nala list --upgradeable'
abbr -a show 'nala show'
abbr -a autopurge 'nala autopurge'
abbr -a autoremove 'nala autoremove'
abbr -a debian 'proot-distro login debian --user $username --shared-tmp'
abbr -a zrun 'proot-distro login debian --user $username --shared-tmp -- env DISPLAY=:1.0 MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform'
abbr -a zrunhud 'proot-distro login debian --user $username --shared-tmp -- env DISPLAY=:1.0 MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform GALLIUM_HUD=fps'
abbr -a hud 'GALLIUM_HUD=fps'

" >> $HOME/.config/fish/config.fish

# Set Fish as default shell and Tide prompt
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
fish -c "fisher install IlanCosman/tide@v6"
fish -c "set -U fish_greeting"
echo fish | tee -a /etc/shells
chsh -s fish

# Download Wallpaper
wget https://raw.githubusercontent.com/GiGiDKR/Termux_XFCE/main/peakpx.jpg
wget https://raw.githubusercontent.com/GiGiDKR/Termux_XFCE/main/dark_waves.png
wget https://raw.githubusercontent.com/GiGiDKR/Termux_XFCE/main/mac.jpg
wget https://raw.githubusercontent.com/GiGiDKR/Termux_XFCE/main/japan1.jpg
wget https://raw.githubusercontent.com/GiGiDKR/Termux_XFCE/main/japan2.jpg
wget https://raw.githubusercontent.com/GiGiDKR/Termux_XFCE/main/japan3.jpg
mv peakpx.jpg $PREFIX/share/backgrounds/xfce/
mv dark_waves.png $PREFIX/share/backgrounds/xfce/
mv mac.jpg $PREFIX/share/backgrounds/xfce/
mv japan1.jpg $PREFIX/share/backgrounds/xfce/
mv japan2.jpg $PREFIX/share/backgrounds/xfce/
mv japan3.jpg $PREFIX/share/backgrounds/xfce/

# Install WhiteSur-Dark Theme
wget https://github.com/vinceliuice/WhiteSur-gtk-theme/archive/refs/tags/2024-05-01.zip
unzip 2024-05-01.zip
tar -xf WhiteSur-gtk-theme-2024-05-01/release/WhiteSur-Dark.tar.xz
mv WhiteSur-Dark/ $PREFIX/share/themes/
rm -rf WhiteSur*
rm 2024-05-01.zip

# Install Fluent Cursor Icon Theme
wget https://github.com/vinceliuice/Fluent-icon-theme/archive/refs/tags/2024-02-25.zip
unzip 2024-02-25.zip
mv Fluent-icon-theme-2024-02-25/cursors/dist $PREFIX/share/icons/ 
mv Fluent-icon-theme-2024-02-25/cursors/dist-dark $PREFIX/share/icons/
rm -rf $HOME/Fluent*
rm 2024-02-25.zip

# Setup Fonts
mkdir -p $HOME/.fonts

wget https://github.com/microsoft/cascadia-code/releases/download/v2111.01/CascadiaCode-2111.01.zip
unzip CascadiaCode-2111.01.zip
mv otf/static/* $HOME/.fonts/ && rm -rf otf
mv ttf/* $HOME/.fonts/ && rm -rf ttf/
rm -rf woff2/ && rm CascadiaCode-2111.01.zip

wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Meslo.zip
unzip Meslo.zip -d $HOME/.fonts/
rm Meslo.zip
rm $HOME/.fonts/LICENSE.txt
rm $HOME/.fonts/README.md

wget https://github.com/GiGiDKR/Termux_XFCE/raw/main/NotoColorEmoji-Regular.ttf
mv NotoColorEmoji-Regular.ttf .fonts

wget https://github.com/GiGiDKR/Termux_XFCE/raw/main/font.ttf
mv font.ttf .termux/font.ttf

wget https://github.com/GiGiDKR/Termux_XFCE/raw/main/config.tar.gz
tar -xvzf config.tar.gz
rm config.tar.gz

# Define packages to install in Debian proot
pkgs_proot=('sudo' 'wget' 'nala' 'jq' 'curl')

# Install Debian proot
proot-distro install debian
proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 apt update
proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 apt upgrade -y
proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 apt install "${pkgs_proot[@]}" -y -o Dpkg::Options::="--force-confold"

# Create user in Debian proot
proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 groupadd storage
proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 groupadd wheel
proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 useradd -m -g users -G wheel,audio,video,storage -s /usr/bin/bash "$username"

# Add user to sudoers in Debian proot
chmod u+rw $PREFIX/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers
echo "$username ALL=(ALL) NOPASSWD:ALL" | tee -a $PREFIX/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers > /dev/null
chmod u-w  $PREFIX/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers

# Set proot DISPLAY
echo "
export DISPLAY=:1.0
" >> $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.bashrc

# Set proot bash aliases
echo "
alias zink='MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform'
alias hud='GALLIUM_HUD=fps'
alias ls='eza -lF --icons'
alias l='eza -1 --icons'
alias la='eza -lF -a --icons'
alias ll='eza -T --icons'
alias dir='eza -lF --icons'
alias ..='cd ..'
alias q='exit'
alias c='clear'
alias cat='bat'
alias apt='sudo nala'
alias install='sudo nala install -y'
alias remove='sudo nala remove -y'
alias list='nala list --upgradeable'
alias show='nala show'
alias search='nala search'
alias start='clear && echo   Veuillez éxécuter depuis TERMUX et non DEBIAN proot.'

" >> $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.bashrc

# Set proot timezone
timezone=$(getprop persist.sys.timezone)
proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 rm /etc/localtime
proot-distro login debian --shared-tmp -- env DISPLAY=:1.0 cp /usr/share/zoneinfo/$timezone /etc/localtime

# Set theme from XFCE to Debian proot
mkdir -p $PREFIX/var/lib/proot-distro/installed-rootfs/debian/usr/share/icons
cp -r $PREFIX/share/icons/dist-dark $PREFIX/var/lib/proot-distro/installed-rootfs/debian/usr/share/icons/dist-dark

cat <<'EOF' > $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.Xresources
Xcursor.theme: dist-dark
EOF

mkdir -p $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.fonts/
cp $HOME/.fonts/NotoColorEmoji-Regular.ttf $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.fonts/

# Create autostart directory
if [ ! -d "$HOME/.config/autostart" ]; then
    mkdir -p "$HOME/.config/autostart"
fi

<<COMMENT
Example of application autostart
#cp $PREFIX/var/lib/proot-distro/installed-rootfs/debian/usr/share/applications/%ApplicationName%.desktop $HOME/.config/autostart/
#sed -i 's|^Exec=.*$|Exec=prun %ApplicationName%-c .config/%ApplicationName%/%ApplicationName%.conf|' $HOME/.config/autostart/%ApplicationName%.desktop
#chmod +x $HOME/.config/autostart/*.desktop
COMMENT

# Run program
cat <<'EOF' > $PREFIX/bin/prun
#!/bin/bash
varname=$(basename $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/*)
pd login debian --user $varname --shared-tmp -- env DISPLAY=:1.0 $@

EOF
chmod +x $PREFIX/bin/prun

# Copy to menu
cat <<'EOF' > $PREFIX/bin/cp2menu
#!/bin/bash

cd

user_dir="$PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/"

username=$(basename "$user_dir"/*)

action=$(zenity --list --title="Choose Action" --text="Select an action:" --radiolist --column="" --column="Action" TRUE "Copy .desktop file" FALSE "Remove .desktop file")

if [[ -z $action ]]; then
  zenity --info --text="No action selected. Quitting..." --title="Operation Cancelled"
  exit 0
fi

if [[ $action == "Copy .desktop file" ]]; then
  selected_file=$(zenity --file-selection --title="Select .desktop File" --file-filter="*.desktop" --filename="$PREFIX/var/lib/proot-distro/installed-rootfs/debian/usr/share/applications")

  if [[ -z $selected_file ]]; then
    zenity --info --text="No file selected. Quitting..." --title="Operation Cancelled"
    exit 0
  fi

  desktop_filename=$(basename "$selected_file")

  cp "$selected_file" "$PREFIX/share/applications/"
  sed -i "s/^Exec=\(.*\)$/Exec=pd login debian --user $username --shared-tmp -- env DISPLAY=:1.0 \1/" "$PREFIX/share/applications/$desktop_filename"

  zenity --info --text="Operation completed successfully!" --title="Success"
elif [[ $action == "Remove .desktop file" ]]; then
  selected_file=$(zenity --file-selection --title="Select .desktop File to Remove" --file-filter="*.desktop" --filename="$PREFIX/share/applications")

  if [[ -z $selected_file ]]; then
    zenity --info --text="No file selected for removal. Quitting..." --title="Operation Cancelled"
    exit 0
  fi

  desktop_filename=$(basename "$selected_file")

  rm "$selected_file"

  zenity --info --text="File '$desktop_filename' has been removed successfully!" --title="Success"
fi

EOF
chmod +x $PREFIX/bin/cp2menu

echo "[Desktop Entry]
Version=1.0
Type=Application
Name=cp2menu
Comment=
Exec=cp2menu
Icon=edit-move
Categories=System;
Path=
Terminal=false
StartupNotify=false
" > $PREFIX/share/applications/cp2menu.desktop 
chmod +x $PREFIX/share/applications/cp2menu.desktop 

# App-Installer
cat <<'EOF' > "$PREFIX/bin/app-installer"
#!/bin/bash

INSTALLER_DIR="$HOME/.App-Installer"
REPO_URL="https://github.com/GiGiDKR/App-Installer.git"
DESKTOP_DIR="$HOME/Desktop"
APP_DESKTOP_FILE="$DESKTOP_DIR/app-installer.desktop"

if [ ! -d "$INSTALLER_DIR" ]; then
    # Directory doesn't exist, clone the repository
    git clone "$REPO_URL" "$INSTALLER_DIR"
    if [ $? -eq 0 ]; then
        echo "Repository cloned successfully."
    else
        echo "Failed to clone repository. Exiting."
        exit 1
    fi
else
    echo "Directory already exists. Skipping clone."
    "$INSTALLER_DIR/app-installer"
fi

if [ ! -f "$APP_DESKTOP_FILE" ]; then
    # .desktop file doesn't exist, create it
    echo "[Desktop Entry]
    Version=1.0
    Type=Application
    Name=App Installer
    Comment=
    Exec=$PREFIX/bin/app-installer
    Icon=package-install
    Categories=System;
    Path=
    Terminal=false
    StartupNotify=false
" > "$APP_DESKTOP_FILE"
    chmod +x "$APP_DESKTOP_FILE"
fi

chmod +x "$INSTALLER_DIR/app-installer"

EOF
chmod +x "$PREFIX/bin/app-installer"
bash $PREFIX/bin/app-installer

if [ ! -f "$HOME/Desktop/app-installer.desktop" ]; then
echo "[Desktop Entry]
Version=1.0
Type=Application
Name=App Installer
Comment=
Exec=$PREFIX/bin/app-installer
Icon=package-install
Categories=System;
Path=
Terminal=false
StartupNotify=false
" > "$HOME/Desktop/app-installer.desktop"
chmod +x "$HOME/Desktop/app-installer.desktop"
fi

# launch script
cat << 'EOT' > $PREFIX/bin/start
#!/bin/bash

pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 > /dev/null 2>&1

XDG_RUNTIME_DIR=${TMPDIR} termux-x11 :1.0 & > /dev/null 2>&1
sleep 1

am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity > /dev/null 2>&1
sleep 1

MESA_NO_ERROR=1 MESA_GL_VERSION_OVERRIDE=4.3COMPAT MESA_GLES_VERSION_OVERRIDE=3.2 virgl_test_server_android --angle-gl & > /dev/null 2>&1

env DISPLAY=:1.0 GALLIUM_DRIVER=virpipe dbus-launch --exit-with-session xfce4-session & > /dev/null 2>&1

export PULSE_SERVER=127.0.0.1 > /dev/null 2>&1

sleep 5
process_id=$(ps -aux | grep '[x]fce4-screensaver' | awk '{print $2}')
kill "$process_id" > /dev/null 2>&1

EOT

chmod +x $PREFIX/bin/start

# Shutdown script
cat <<'EOF' > $PREFIX/bin/stop
#!/bin/bash

# Check if Apt, dpkg, or Nala is running in Termux or Proot
if pgrep -f 'apt|apt-get|dpkg|nala'; then
  zenity --info --text="Software is currently installing in Termux or Proot. Please wait for these processes to finish before continuing."
  exit 1
fi

# Get the process IDs of Termux-X11 and XFCE sessions
termux_x11_pid=$(pgrep -f /system/bin/app_process.*com.termux.x11.Loader)
xfce_pid=$(pgrep -f "xfce4-session")

# Add debug output
echo "Termux-X11 PID: $termux_x11_pid"
echo "XFCE PID: $xfce_pid"

# Check if the process IDs exist
if [ -n "$termux_x11_pid" ] && [ -n "$xfce_pid" ]; then
  # Kill the processes
  kill -9 "$termux_x11_pid" "$xfce_pid"
  zenity --info --text="Termux-X11 and XFCE sessions closed."
else
  zenity --info --text="Termux-X11 or XFCE session not found."
fi

info_output=$(termux-info)
pid=$(echo "$info_output" | grep -o 'TERMUX_APP_PID=[0-9]\+' | awk -F= '{print $2}')
kill "$pid"

exit 0

EOF

chmod +x $PREFIX/bin/stop

echo "[Desktop Entry]
Version=1.0
Type=Application
Name=Stop Termux X11
Comment=
Exec=stop
Icon=system-shutdown
Categories=System;
Path=
StartupNotify=false
" > $HOME/Desktop/stop.desktop
chmod +x $HOME/Desktop/stop.desktop
mv $HOME/Desktop/stop.desktop $PREFIX/share/applications

# Termux-X11 setup
if ! pm list packages | grep -q "com.termux.x11"; then
    clear -x
    banner
    echo ""
    echo "  Termux-X11 n'est pas installé. Installation de l'APK..." 
    echo ""
    read -n 1 -s -r -p "  Appuyez sur n'importe quelle touche pour continuer..."
    wget https://github.com/termux/termux-x11/releases/download/nightly/app-arm64-v8a-debug.apk
    mv app-arm64-v8a-debug.apk $HOME/storage/downloads/
    clear -x
    termux-open $HOME/storage/downloads/app-arm64-v8a-debug.apk
    banner
    echo ""
    echo "  Veuillez installer Termux-X11."
    echo ""
    read -n 1 -s -r -p "  Appuyez sur n'importe quelle touche pour continuer..."
    rm $HOME/storage/downloads/app-arm64-v8a-debug.apk
else
    clear -x
    banner
    echo "  Termux-X11 est déjà installé."
fi

# PyPI install additional tools in Termux
install_tool() {
    local tool=$1
    echo "Installation de $tool avec pip..."
    pip install $tool
}

clear
banner
echo ""
echo "  Installation terminée !"
echo ""
echo "  Pour lancer XFCE4, exécutez :               start"
echo "  Pour accéder à DEBIAN exécutez :            debian"
echo ""

echo " Des outils en ligne de commande sont disponibles :"
read -p "  Voulez-vous en installer dans TERMUX ? (o/n) " install_tools

if [[ $install_tools =~ ^[Oo]$ ]]; then
    pkg install -y python
    pip install --upgrade pip

    while true; do
        clear
        banner
        echo ""
        echo "  Saisir les chiffres correspondants (séparés par des espaces) :"
        echo ""
        echo "  1 : Speedtest-cli (Test de bande passante Internet)"
        echo "  2 : Qobuz-dl (Téléchargement audio depuis qobuz.com)"
        echo "  3 : Ranger (Gestionnaire de fichiers en ligne de commande)"
        echo ""       
        echo "  q : Quitter la sélection"
        echo ""
        
        read -p " Votre choix : " choices

        if [[ $choices =~ [Qq] ]]; then
            break
        fi

        for choice in $choices; do
            case $choice in
                1)
                    install_tool speedtest-cli
                    ;;
                2)
                    install_tool qobuz-dl
                    ;;
                3)
                    install_tool ranger-fm
                    ;;
                *)
                    echo "Choix non valide : $choice"
                    ;;
            esac
        done

        read -p "Voulez-vous installer d'autres outils ? (o/n) " continue_install
        if [[ ! $continue_install =~ ^[Oo]$ ]]; then
            break
        fi
    done
fi

clear
banner
echo ""
echo "  Installation terminée !"
echo ""
echo "  Pour lancer XFCE4, exécutez :               start"
echo "  Pour accéder à DEBIAN exécutez :            debian"
echo ""

while true; do
    read -p "  Configurer le prompt TIDE ? (o/n/q pour quitter) " tidle
    case $tidle in
        [oO])
            fish -c "tide configure" 
            break
            ;;
        [nN])
            clear
            banner
            echo ""
            echo '  Pour configurer TIDE plus tard, exécutez : "tide configure"'
            sleep 5
            break
            ;;
        [qQ])
            echo ""
            echo "  Vous quittez sans configurer TIDE."
            sleep 5
            break
            ;;
        *)
            clear
            banner
            echo ""
            echo "  Installation terminée !"
            echo ""
            echo "  Pour lancer XFCE4, exécutez :               start"
            echo "  Pour accéder à DEBIAN exécutez :            debian"
            echo ""
            echo "  Entrée non valide."
            echo "  Veuillez saisir o (oui), n (non), ou q (quitter)."
            ;;
    esac
done

rm $HOME/install.sh
source $PREFIX/etc/bash.bashrc
termux-reload-settings
clear

# Termux color scheme selector
read -p "Voulez-vous sélectionner un thème de couleur pour Termux ? (o/n) " select_theme

if [[ $select_theme =~ ^[Oo]$ ]]; then
    wget https://raw.githubusercontent.com/GiGiDKR/Termux_XFCE/main/themeselector.sh -O $HOME/themeselector.sh
    chmod +x $HOME/themeselector.sh
    $HOME/themeselector.sh
    rm $HOME/themeselector.sh
    clear
fi

echo ""
echo "  Installation terminée !"
echo ""
echo "  Pour lancer XFCE4, exécutez :               start"
echo "  Pour accéder à DEBIAN exécutez :            debian"

exec fish
