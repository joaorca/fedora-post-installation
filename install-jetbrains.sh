#!/usr/bin/env bash

# Cores para o terminal
ERROR_COLOR='\033[7;31m'
TITLE_COLOR='\033[1;31m'
NC='\033[0m'

METADATA=$(curl -s "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release" | sed 's/[{,}]/\n/g')
BUILD=$(echo "$METADATA" | grep '"build"' | cut -d'"' -f4)
JETBRAINS_VERSION="${BUILD}"
JETBRAINS_URL="https://download-cdn.jetbrains.com/toolbox/jetbrains-toolbox-${JETBRAINS_VERSION}.tar.gz"

echo -e "Versão detectada: ${JETBRAINS_VERSION}"
echo -e "URL de download: ${JETBRAINS_URL}"

JETBRAINS_TMP_FILE="jetbrains-toolbox.tar.gz"
JETBRAINS_FOLDER="/opt/jetbrains-toolbox"

#if [ $(id -u) != 0 ]; then
#  echo -e "${ERROR_COLOR}O script deve ser executado como root${NC}"
#  exit 1
#fi

if [ -f "${JETBRAINS_FOLDER}/jetbrains-toolbox" ]; then
  echo -e "JetBrains-Toolbox já instalado em ${JETBRAINS_FOLDER}"
  exit 0
fi

echo -e "\n${TITLE_COLOR}Instalando JetBrains-Toolbox (Versão: ${JETBRAINS_VERSION})${NC}"

# Download
if ! [ -f /tmp/${JETBRAINS_TMP_FILE} ]; then
  sudo wget -q --show-progress "${JETBRAINS_URL}" -O /tmp/jetbrains/${JETBRAINS_TMP_FILE}
fi

sudo tar -zxf /tmp/jetbrains/${JETBRAINS_TMP_FILE} -C /tmp/jetbrains --strip-components=1
/tmp/jetbrains/bin/jetbrains-toolbox --install
#mkdir -p ${JETBRAINS_FOLDER}
#mv /tmp/jetbrains-toolbox*/bin/* ${JETBRAINS_FOLDER}/
#chmod +x ${JETBRAINS_FOLDER}/jetbrains-toolbox

echo -e "\n${TITLE_COLOR}Instalação concluída!${NC}"
echo -e "Execute: ${JETBRAINS_FOLDER}/jetbrains-toolbox para iniciar.\n"
