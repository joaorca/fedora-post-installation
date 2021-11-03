#!/usr/bin/env bash

ERROR_COLOR='\033[7;31m'
TITLE_COLOR='\033[1;31m'
NC='\033[0m'

RAMBOX_VERSION="0.7.9"
RAMBOX_DISTRO="linux-x86_64"
RAMBOX_URL="https://github.com/ramboxapp/community-edition/releases/download/${RAMBOX_VERSION}/Rambox-${RAMBOX_VERSION}-${RAMBOX_DISTRO}.rpm"
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
  wget -q ${RAMBOX_URL} --show-progress -O /tmp/${RAMBOX_TMP_FILE} 
fi
dnf install /tmp/${RAMBOX_TMP_FILE} --assumeyes

echo -e "\nDone...\n"
