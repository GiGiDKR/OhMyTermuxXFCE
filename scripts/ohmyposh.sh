#!/bin/bash

## Author GiGiDKR
## Date 21/07/2024
## Rev 1.0.0

clear

pkg update -y

clear
echo "          Installation Nerd Font "

mkdir -p ~/.local/share/fonts
cd ~/.local/share/fonts && curl -fLO https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/JetBrainsMono/Ligatures/Regular/JetBrainsMonoNerdFont-Regular.ttf
cp ~/.local/share/fonts/JetBrainsMonoNerdFont-Regular.ttf ~/.termux/font.ttf

clear
echo "           Installation oh-my-posh "
curl -s https://ohmyposh.dev/install.sh | bash -s -- -d  /data/data/com.termux/files/usr/bin

if [ ! -f ~/.bashrc ]; then
    echo "          Création du fichier .bashrc"
    touch ~/.bashrc
fi

if ! grep -q 'eval "$(./oh-my-posh init bash)"' ~/.bashrc; then
    echo 'eval "$(./oh-my-posh init bash)"' >> ~/.bashrc
fi

echo "          Configuration terminée !"
termux-reload-settings