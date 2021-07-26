#!/usr/bin/env bash

ERROR_COLOR='\033[7;31m'
TITLE_COLOR='\033[1;31m'
NC='\033[0m'

_FLATPAK_PACKAGES=(
  com.spotify.Client
  com.transmissionbt.Transmission
  com.calibre_ebook.calibre
  io.github.wereturtle.ghostwriter
  us.zoom.Zoom
  rest.insomnia.Insomnia
)

FLATPAK_PACKAGES=(
  com.axosoft.GitKraken
  com.getpostman.Postman
  org.videolan.VLC
  com.discordapp.Discord
)

echo -e "\n${TITLE_COLOR}Add the Flathub repository${NC}"
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

for PACKAGE in ${FLATPAK_PACKAGES[@]}
do
  echo -e "\n${TITLE_COLOR}Instalando pacote flatpak: ${PACKAGE}${NC}"
  flatpak install flathub ${PACKAGE} -y
done

echo -e "\nDone...\n"
