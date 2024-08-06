#!/bin/zsh

# Unofficial Zsh Strict Mode
set -euo pipefail
IFS=$'\n\t'

finish() {
  local ret=$?
  if [ ${ret} -ne 0 ] && [ ${ret} -ne 130 ]; then
    echo
    echo "ERROR: Failed to setup XFCE on Termux."
    echo "Please refer to the error message(s) above"
  fi
}

trap finish EXIT

username="$1"

pkgs_proot=('sudo' 'wget' 'nala' 'jq' 'flameshot' 'conky-all')

# Installer Debian proot
pd install debian
pd login debian --shared-tmp -- env DISPLAY=:1.0 apt update
pd login debian --shared-tmp -- env DISPLAY=:1.0 apt upgrade -y
pd login debian --shared-tmp -- env DISPLAY=:1.0 apt install "${pkgs_proot[@]}" -y -o Dpkg::Options::="--force-confold"

# Créer l'utilisateur
pd login debian --shared-tmp -- env DISPLAY=:1.0 groupadd storage
pd login debian --shared-tmp -- env DISPLAY=:1.0 groupadd wheel
pd login debian --shared-tmp -- env DISPLAY=:1.0 useradd -m -g users -G wheel,audio,video,storage -s /bin/zsh "$username"

# Ajouter l'utilisateur aux sudoers
chmod u+rw $PREFIX/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers
echo "$username ALL=(ALL) NOPASSWD:ALL" | tee -a $PREFIX/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers > /dev/null
chmod u-w $PREFIX/var/lib/proot-distro/installed-rootfs/debian/etc/sudoers

# Définir DISPLAY pour proot
echo "export DISPLAY=:1.0" >> $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.zshrc

# Définir les alias pour proot
echo "
alias zink='MESA_LOADER_DRIVER_OVERRIDE=zink TU_DEBUG=noconform '
alias hud='GALLIUM_HUD=fps '
alias l='eza -1 --icons'
alias ls='eza --icons'
alias ll='eza -lF -a  --icons --total-size  --no-permissions  --no-time --no-user'
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
" >> $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.zshrc

# Définir le fuseau horaire pour proot
timezone=$(getprop persist.sys.timezone)
pd login debian --shared-tmp -- env DISPLAY=:1.0 rm /etc/localtime
pd login debian --shared-tmp -- env DISPLAY=:1.0 cp /usr/share/zoneinfo/$timezone /etc/localtime

# Installer Oh-My-Zsh et les plugins
pd login debian --shared-tmp -- env DISPLAY=:1.0 wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O - | zsh || true
pd login debian --shared-tmp -- env DISPLAY=:1.0 git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.oh-my-zsh/custom/themes/powerlevel10k || true
pd login debian --shared-tmp -- env DISPLAY=:1.0 git clone https://github.com/zsh-users/zsh-autosuggestions $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.oh-my-zsh/custom/plugins/zsh-autosuggestions || true
pd login debian --shared-tmp -- env DISPLAY=:1.0 git clone https://github.com/zsh-users/zsh-syntax-highlighting $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting || true
pd login debian --shared-tmp -- env DISPLAY=:1.0 git clone https://github.com/zsh-users/zsh-completions $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.oh-my-zsh/custom/plugins/zsh-completions || true
pd login debian --shared-tmp -- env DISPLAY=:1.0 git clone https://github.com/MichaelAquilina/zsh-you-should-use $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.oh-my-zsh/custom/plugins/you-should-use || true
pd login debian --shared-tmp -- env DISPLAY=:1.0 git clone https://github.com/olets/zsh-abbr $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.oh-my-zsh/custom/plugins/zsh-abbr || true
pd login debian --shared-tmp -- env DISPLAY=:1.0 git clone https://github.com/akash329d/zsh-alias-finder $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.oh-my-zsh/custom/plugins/zsh-alias-finder || true

# Copier la configuration de Oh-My-Zsh
cp -f "$HOME/OhMyTermux/zshrc" "$PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.zshrc"
cp -f "$HOME/OhMyTermux/aliases.zsh" "$PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.oh-my-zsh/custom/aliases.zsh"
cp -f "$HOME/OhMyTermux/p10k.zsh" "$PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.p10k.zsh"

# Définir les thèmes et les polices pour proot
cp -r $PREFIX/share/icons/dist-dark $PREFIX/var/lib/proot-distro/installed-rootfs/debian/usr/share/icons/dist-dark

cat <<'EOF' > $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.Xresources
Xcursor.theme: dist-dark
EOF

mkdir -p $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.fonts/
cp $HOME/.fonts/NotoColorEmoji-Regular.ttf $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.fonts/

# Configurer l'accélération matérielle
pd login debian --shared-tmp -- env DISPLAY=:1.0 wget https://github.com/GiGIDKR/Termux_XFCE/raw/main/mesa-vulkan-kgsl_24.1.0-devel-20240120_arm64.deb
pd login debian --shared-tmp -- env DISPLAY=:1.0 sudo apt install -y ./mesa-vulkan-kgsl_24.1.0-devel-20240120_arm64.deb

# Nettoyer les fichiers temporaires
rm -f $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.zshrc
rm -f $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.oh-my-zsh/custom/aliases.zsh
rm -f $PREFIX/var/lib/proot-distro/installed-rootfs/debian/home/$username/.p10k.zsh

echo "Installation terminée !"