#!/usr/bin/env bash

ERROR_COLOR='\033[7;31m'
TITLE_COLOR='\033[1;31m'
NC='\033[0m'

JETBRAINS_URL="https://download.jetbrains.com/toolbox/jetbrains-toolbox-1.19.7784.tar.gz"
JETBRAINS_TMP_FILE="jetbrains-toolbox.tar.gz"
JETBRAINS_FOLDER="/opt/jetbrains-toolbox"

if [ $(id -u) != 0 ]; then
  echo -e "${ERROR_COLOR}O script deve ser executado como root${NC}"
  exit
fi

echo -e "\n${TITLE_COLOR}Instalando JetBrains-Toolbox${NC}"

if [ -f ${JETBRAINS_FOLDER}/jetbrains-toolbox ]; then
  echo -e "JetBrains-Toolbox já instalado"
else
  if ! [ -f /tmp/${JETBRAINS_TMP_FILE} ]; then
    wget -q ${JETBRAINS_URL} --show-progress -O /tmp/${JETBRAINS_TMP_FILE}
  fi
  tar -zxf /tmp/${JETBRAINS_TMP_FILE} -C /tmp
  mkdir -p ${JETBRAINS_FOLDER}
  mv /tmp/jetbrains-toolbox*/jetbrains-toolbox ${JETBRAINS_FOLDER}/jetbrains-toolbox
  chmod 0777 ${JETBRAINS_FOLDER}
fi

echo -e "\nDone...\n"
