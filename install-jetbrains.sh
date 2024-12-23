#!/usr/bin/env bash

ERROR_COLOR='\033[7;31m'
TITLE_COLOR='\033[1;31m'
NC='\033[0m'

JETBRAINS_VERSION="2.5.2.35332"
JETBRAINS_URL="https://download-cdn.jetbrains.com/toolbox/jetbrains-toolbox-${JETBRAINS_VERSION}.tar.gz"
JETBRAINS_TMP_FILE="jetbrains-toolbox.tar.gz"
JETBRAINS_FOLDER="/opt/jetbrains-toolbox"

if [ $(id -u) != 0 ]; then
  echo -e "${ERROR_COLOR}O script deve ser executado como root${NC}"
  exit
fi

if [ -f ${JETBRAINS_FOLDER}/jetbrains-toolbox ]; then
  echo -e "JetBrains-Toolbox já instalado"
  exit
fi

echo -e "\n${TITLE_COLOR}Instalando JetBrains-Toolbox${NC}"

if ! [ -f /tmp/${JETBRAINS_TMP_FILE} ]; then
  wget -q ${JETBRAINS_URL} --progress=bar:force -O /tmp/${JETBRAINS_TMP_FILE}
fi

tar -zxf /tmp/${JETBRAINS_TMP_FILE} -C /tmp
mkdir -p ${JETBRAINS_FOLDER}
mv /tmp/jetbrains-toolbox*/jetbrains-toolbox ${JETBRAINS_FOLDER}/jetbrains-toolbox
chmod 0777 ${JETBRAINS_FOLDER}

echo -e "\nDone...\n"
