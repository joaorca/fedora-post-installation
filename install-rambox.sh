#!/usr/bin/env bash

ERROR_COLOR='\033[7;31m'
TITLE_COLOR='\033[1;31m'
NC='\033[0m'

RAMBOX_VERSION="2.0.8"
RAMBOX_DISTRO="linux-x64"
RAMBOX_URL="https://github.com/ramboxapp/download/releases/download/v${RAMBOX_VERSION}/Rambox-${RAMBOX_VERSION}-${RAMBOX_DISTRO}.rpm"
RAMBOX_TMP_FILE="rambox-${RAMBOX_VERSION}-${RAMBOX_DISTRO}.rpm"

if [ $(id -u) != 0 ]; then
  echo -e "${ERROR_COLOR}O script deve ser executado como root${NC}"
  exit
fi

if rpm -qa | grep -iq rambox; then
  echo -e "RAMBOX já instalado"
fi

echo -e "\n${TITLE_COLOR}Instalando RAMBOX${NC}"

if ! [ -f /tmp/${RAMBOX_TMP_FILE} ]; then
   echo -e ${RAMBOX_URL}
   wget -q ${RAMBOX_URL} --show-progress -O /tmp/${RAMBOX_TMP_FILE} 
fi
dnf install /tmp/${RAMBOX_TMP_FILE} --assumeyes

echo -e "\nDone...\n"
