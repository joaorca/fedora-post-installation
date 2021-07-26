#!/usr/bin/env bash

ERROR_COLOR='\033[7;31m'
TITLE_COLOR='\033[1;31m'
NC='\033[0m'

INSYNC_URL="https://d2t3ff60b2tol4.cloudfront.net/builds/insync-3.4.3.40990-fc34.x86_64.rpm"
INSYNC_TMP_FILE="insync.rpm"

if [ $(id -u) != 0 ]; then
  echo -e "${ERROR_COLOR}O script deve ser executado como root${NC}"
  exit
fi

if rpm -qa | grep -iq insync; then
  echo -e "INSYNC já instalado"
  exit
fi

echo -e "\n${TITLE_COLOR}Instalando INSYNC${NC}"

if ! [ -f /tmp/${INSYNC_TMP_FILE} ]; then
  wget -q ${INSYNC_URL} --show-progress -O /tmp/${INSYNC_TMP_FILE} 
fi
dnf install /tmp/${INSYNC_TMP_FILE} --assumeyes

echo -e "\nDone...\n"
