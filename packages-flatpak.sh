#!/usr/bin/env bash

ERROR_COLOR='\033[7;31m'
TITLE_COLOR='\033[1;31m'
NC='\033[0m'

FLATPAK_PACKAGES=(
  com.spotify.Client
  com.getpostman.Postman
  com.transmissionbt.Transmission
  com.calibre_ebook.calibre
  com.meetfranz.Franz
  com.sublimetext.three
  org.videolan.VLC
  org.libreoffice.LibreOffice
  io.github.wereturtle.ghostwriter
  us.zoom.Zoom
)

echo -e "\n${TITLE_COLOR}Install Flatpak${NC}"
sudo apt install -y -qq flatpak

echo -e "\n${TITLE_COLOR}Install the Software Flatpak plugin${NC}"
sudo apt install -y -qq gnome-software-plugin-flatpak

echo -e "\n${TITLE_COLOR}Add the Flathub repository${NC}"
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

for PACKAGE in ${FLATPAK_PACKAGES[@]}
do
  echo -e "\n${TITLE_COLOR}Instalando pacote FLATPAK ${PACKAGE}${NC}"
  flatpak install flathub ${PACKAGE} -y
done

echo -e "\nDone...\n"
