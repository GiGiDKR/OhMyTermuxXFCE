#!/bin/bash

 THEMES_DIR="$HOME//.termux"  
 TERMUX_COLORS="$HOME/.termux/colors.properties" 
 BACKUP_COLORS="$HOME/.termux/colors.properties.backup" 

banner() {
  clear
    echo "                                                                  "
    echo "█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗"
    echo "╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝"
    echo "                                                                  "
    echo "    ████████╗███████╗██████╗ ███╗   ███╗██╗   ██╗██╗  ██╗         "
    echo "    ╚══██╔══╝██╔════╝██╔══██╗████╗ ████║██║   ██║╚██╗██╔╝         "
    echo "       ██║   █████╗  ██████╔╝██╔████╔██║██║   ██║ ╚███╔╝          "
    echo "       ██║   ██╔══╝  ██╔══██╗██║╚██╔╝██║██║   ██║ ██╔██╗          "
    echo "       ██║   ███████╗██║  ██║██║ ╚═╝ ██║╚██████╔╝██╔╝ ██╗         "
    echo "       ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝         "
    echo "                                                                  "
    echo "        ████████╗██╗  ██╗███████╗███╗   ███╗███████╗              "
    echo "        ╚══██╔══╝██║  ██║██╔════╝████╗ ████║██╔════╝              "
    echo "           ██║   ███████║█████╗  ██╔████╔██║█████╗                "
    echo "           ██║   ██╔══██║██╔══╝  ██║╚██╔╝██║██╔══╝                "
    echo "           ██║   ██║  ██║███████╗██║ ╚═╝ ██║███████╗              "
    echo "           ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝     ╚═╝╚══════╝              "
    echo "                                                                  "
    echo "███████╗███████╗██╗     ███████╗ ██████╗████████╗ ██████╗ ██████╗ "
    echo "██╔════╝██╔════╝██║     ██╔════╝██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗"
    echo "███████╗█████╗  ██║     █████╗  ██║        ██║   ██║   ██║██████╔╝"
    echo "╚════██║██╔══╝  ██║     ██╔══╝  ██║        ██║   ██║   ██║██╔══██╗"
    echo "███████║███████╗███████╗███████╗╚██████╗   ██║   ╚██████╔╝██║  ██║"
    echo "╚══════╝╚══════╝╚══════╝╚══════╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝"
    echo "                                                                  "
    echo "█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗█████╗"
    echo "╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝╚════╝"
    echo ""
	echo ""
}

banner 

 if [ -f "$TERMUX_COLORS" ]; then
 	cp "$TERMUX_COLORS" "$BACKUP_COLORS"
 	echo ""
 	echo "Thème initial sauvegardé dans $BACKUP_COLORS" 
 else
 	echo ""
 	echo "Aucun thème initial trouvé. Création d'un nouveau." 
 	touch "$TERMUX_COLORS"
fi 

 appliquer_theme() {
 	local theme_file="$1" 
 	local theme_name="$2" 
 	
 	cp "$theme_file" "$TERMUX_COLORS" 
 	
 	termux-reload-settings
 	
 	clear
 	banner
 	echo "                        ${theme_name^^}"
 	echo ""
 	echo ""
 	echo "                       Appliquer :  Y"
 	echo "                      Suivant : Entrée"
 	read -p "" reponse 
 		if [[ $reponse == "Y" || $reponse == "y" ]]; then
 			clear
 			echo ""
 			echo "          Thème ${theme_name^^} conservé. Au revoir !" 
 			exit 0 
 			fi 
 } 

 for theme_file in "$THEMES_DIR"/*.properties; do
 	theme_name=$(basename "$theme_file" .properties) 
 	appliquer_theme "$theme_file" "$theme_name" 
 done 

clear
banner
echo ""
echo "Tous les thèmes ont été parcourus sans qu'aucun ne soit choisi." 
  
 if [ -f "$BACKUP_COLORS" ]; then 
 	cp "$BACKUP_COLORS" "$TERMUX_COLORS" 
 	termux-reload-settings
 	echo ""
 	echo "     Le thème initial a été restauré automatiquement." 
 else 
  	echo ""
 	echo "Aucune sauvegarde de thème trouvée. Le dernier a été conservé."
 fi 
 
 echo ""
 echo "                    Au revoir !"
 
