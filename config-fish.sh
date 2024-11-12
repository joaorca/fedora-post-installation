#!/usr/bin/env bash

ERROR_COLOR='\033[7;31m'
TITLE_COLOR='\033[1;31m'
NC='\033[0m'

echo -e "\n${TITLE_COLOR}Definindo ZSH como yerminal padrão${NC}"
chsh -s $(which fish)

echo -e "\n${TITLE_COLOR}Configurando FISHER${NC}"
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher

echo -e "\n${TITLE_COLOR}Instalando Plugins${NC}"
fisher install jhillyerd/plugin-git
fisher install IlanCosman/tide@v5
