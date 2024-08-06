#!/bin/zsh

# Créer le script prun
cat <<'EOF' > $PREFIX/bin/prun
#!/bin/zsh
varname=$(basename $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/*)
pd login debian --user $varname --shared-tmp -- env DISPLAY=:1.0 $@

EOF
chmod +x $PREFIX/bin/prun

# Créer le script zrun
cat <<'EOF' > $PREFIX/bin/zrun
#!/bin/zsh
varname=$(basename $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/*)
pd login debian --user $varname --shared-tmp -- env DISPLAY=:1.0 MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform $@

EOF
chmod +x $PREFIX/bin/zrun

# Créer le script zrunhud
cat <<'EOF' > $PREFIX/bin/zrunhud
#!/bin/zsh
varname=$(basename $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/*)
pd login debian --user $varname --shared-tmp -- env DISPLAY=:1.0 MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform GALLIUM_HUD=fps $@

EOF
chmod +x $PREFIX/bin/zrunhud

# Créer le script cp2menu
cat <<'EOF' > $PREFIX/bin/cp2menu
#!/bin/zsh

cd

user_dir="$PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/"

# Obtenir le nom d'utilisateur à partir du répertoire utilisateur
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

# Créer le fichier .desktop pour cp2menu
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

# Créer le script app-installer
cat <<'EOF' > "$PREFIX/bin/app-installer"
#!/bin/zsh

# Définir les chemins des répertoires
INSTALLER_DIR="$HOME/.App-Installer"
REPO_URL="https://github.com/GiGIDKR/App-Installer.git"
DESKTOP_DIR="$HOME/Desktop"
APP_DESKTOP_FILE="$DESKTOP_DIR/app-installer.desktop"

# Vérifier si le répertoire existe déjà
if [ ! -d "$INSTALLER_DIR" ]; then
    # Le répertoire n'existe pas, cloner le dépôt
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

# Vérifier si le fichier .desktop existe
if [ ! -f "$APP_DESKTOP_FILE" ]; then
    # Le fichier .desktop n'existe pas, le créer
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

# S'assurer que le script app-installer est exécutable
chmod +x "$INSTALLER_DIR/app-installer"

EOF
chmod +x "$PREFIX/bin/app-installer"
bash $PREFIX/bin/app-installer

# Vérifier si le fichier .desktop existe
if [ ! -f "$HOME/Desktop/app-installer.desktop" ]; then
# Le fichier .desktop n'existe pas, le créer
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

# Créer le script start
cat <<'EOF' > start
#!/bin/zsh

# Activer PulseAudio sur le réseau
pulseaudio --start --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1" --exit-idle-time=-1 > /dev/null 2>&1

XDG_RUNTIME_DIR=${TMPDIR} termux-x11 :1.0 & > /dev/null 2>&1
sleep 1

am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity > /dev/null 2>&1
sleep 1

MESA_NO_ERROR=1 MESA_GL_VERSION_OVERRIDE=4.3COMPAT MESA_GLES_VERSION_OVERRIDE=3.2 virgl_test_server_android --angle-gl & > /dev/null 2>&1

#GALLIUM_DRIVER=virpipe MESA_GL_VERSION_OVERRIDE=4.0 program

#MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform program

env DISPLAY=:1.0 GALLIUM_DRIVER=virpipe dbus-launch --exit-with-session xfce4-session & > /dev/null 2>&1
# Définir le serveur audio
export PULSE_SERVER=127.0.0.1 > /dev/null 2>&1

sleep 5
process_id=$(ps -aux | grep '[x]fce4-screensaver' | awk '{print $2}')
kill "$process_id" > /dev/null 2>&1

EOF

chmod +x start
mv start $PREFIX/bin

# Créer le script kill_termux_x11
cat <<'EOF' > $PREFIX/bin/kill_termux_x11
#!/bin/zsh

# Vérifier si Apt, dpkg ou Nala est en cours d'exécution dans Termux ou Proot
if pgrep -f 'apt|apt-get|dpkg|nala'; then
  zenity --info --text="Software is currently installing in Termux or Proot. Please wait for these processes to finish before continuing."
  exit 1
fi

# Obtenir les PID des sessions Termux-X11 et XFCE
termux_x11_pid=$(pgrep -f /system/bin/app_process.*com.termux.x11.Loader)
xfce_pid=$(pgrep -f "xfce4-session")

# Ajouter une sortie de débogage
echo "Termux-X11 PID: $termux_x11_pid"
echo "XFCE PID: $xfce_pid"

# Vérifier si les PID existent
if [ -n "$termux_x11_pid" ] && [ -n "$xfce_pid" ]; then
  # Tuer les processus
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

chmod +x $PREFIX/bin/kill_termux_x11

# Créer le fichier .desktop pour kill_termux_x11
echo "[Desktop Entry]
Version=1.0
Type=Application
Name=Kill Termux X11
Comment=
Exec=kill_termux_x11
Icon=system-shutdown
Categories=System;
Path=
StartupNotify=false
" > $HOME/Desktop/kill_termux_x11.desktop
chmod +x $HOME/Desktop/kill_termux_x11.desktop
mv $HOME/Desktop/kill_termux_x11.desktop $PREFIX/share/applications