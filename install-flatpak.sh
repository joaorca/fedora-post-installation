#!/usr/bin/env bash

ERROR_COLOR='\033[7;31m'
TITLE_COLOR='\033[1;31m'
NC='\033[0m'

FLATPAK_PACKAGES=(
  com.discordapp.Discord
  com.spotify.Client
  com.visualstudio.code
  com.axosoft.GitKraken
  org.flameshot.Flameshot
  rest.insomnia.Insomnia
  #com.getpostman.Postman
  #org.videolan.VLC
  #org.kde.haruna
  #com.transmissionbt.Transmission
  #io.github.wereturtle.ghostwriter
  #com.calibre_ebook.calibre
)

echo -e "\n${TITLE_COLOR}Add the Flathub repository${NC}"
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak remote-modify --enable flathub

for PACKAGE in ${FLATPAK_PACKAGES[@]}
do
  echo -e "\n${TITLE_COLOR}Instalando pacote flatpak: ${PACKAGE}${NC}"
  flatpak install flathub ${PACKAGE} -y
done

echo -e "\nDone...\n"
