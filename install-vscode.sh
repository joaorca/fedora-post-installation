#!/usr/bin/env bash

ERROR_COLOR='\033[7;31m'
TITLE_COLOR='\033[1;31m'
NC='\033[0m'

VSCODE_URL="https://go.microsoft.com/fwlink/?LinkID=760868"
VSCODE_TMP_FILE="vscode.deb"

if [ $(id -u) != 0 ]; then
  echo -e "${ERROR_COLOR}O script deve ser executado como root${NC}"
  exit
fi

echo -e "\n${TITLE_COLOR}Instalando VSCode${NC}"

if dpkg -l | grep -q vscode; then
  echo -e "VSCode já instalado"
else
  if ! [ -f /tmp/${VSCODE_TMP_FILE} ]; then
    wget -q ${VSCODE_URL} --show-progress -O /tmp/${VSCODE_TMP_FILE} 
  fi
  dpkg -i /tmp/${VSCODE_TMP_FILE}
  apt --fix-broken install -y
fi
