#!/data/data/com.termux/files/usr/bin/bash

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
       
EOF
}

clear
banner
echo ""
read -p "Voulez-vous installer nodejs et Electron dans Termux ? (o/n) " electron_install

if [[ $electron_install =~ ^[Oo]$ ]]; then
	if [ `getprop ro.build.version.release` -lt 7 ]; then
    	    echo "Android versions below 7 are not supported!"
        	exit 1
	fi
	pkg upg -y
	clear
	banner
	echo ""
	echo 1.nodejs
	echo 2.nodejs-lts
	echo ""
	read -p "Selectionner la version de nodejs à installer ：" -n 1 njs
	case $njs in
	1)
    	  printf "\nInstallation de nodejs..." && pkg i nodejs -y;;
	2)
      	printf "\nInstallation de nodejs-lts..." && pkg i nodejs-lts -y;;
	*)
    	  printf "\nError!"&&exit;;

	esac
	clear
	banner
	echo ""
	echo "Installation d'Electron..."
	pkg i electron -y> /dev/null 2>&1
	echo "Modification des variables..."
	echo "#!/data/data/com.termux/files/usr/bin/bash" >> $PREFIX/etc/profile.d/electron-nodejs.sh
	echo export ELECTRON_SKIP_BINARY_DOWNLOAD=1 >> $PREFIX/etc/profile.d/electron-nodejs.sh
	echo export ELECTRON_OVERRIDE_DIST_PATH=/data/data/com.termux/files/usr/bin >> $PREFIX/etc/profile.d/electron-nodejs.sh
	source $PREFIX/etc/profile.d/electron-nodejs.sh
	echo ""
	echo "Terminé !"
fi
