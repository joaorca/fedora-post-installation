#!/usr/bin/env bash

ERROR_COLOR='\033[7;31m'
TITLE_COLOR='\033[1;31m'
NC='\033[0m'

NODEJS_VERSION="v16.5.0"
NODEJS_DISTRO="linux-x64"
NODEJS_URL="https://nodejs.org/dist/${NODEJS_VERSION}/node-${NODEJS_VERSION}-${NODEJS_DISTRO}.tar.xz"
NODEJS_FOLDER="/opt/nodejs"

if [ $(id -u) != 0 ]; then
  echo -e "${ERROR_COLOR}O script deve ser executado como root${NC}"
  exit
fi

if [ -d ${NODEJS_FOLDER}/node-${NODEJS_VERSION}-${NODEJS_DISTRO} ]; then
  echo -e "Node ${NODEJS_VERSION} já instalado"
  exit
fi

echo -e "\n${TITLE_COLOR}Instalando NodeJS${NC}"

if ! [ -f /tmp/node-${NODEJS_VERSION}-${NODEJS_DISTRO}.tar.xz ]; then
    wget -q ${NODEJS_URL} --show-progress -P /tmp/
fi

mkdir -p ${NODEJS_FOLDER}
tar xf /tmp/node-${NODEJS_VERSION}-${NODEJS_DISTRO}.tar.xz --directory ${NODEJS_FOLDER}

ln -sf ${NODEJS_FOLDER}/node-v*-${NODEJS_DISTRO}/bin/node  /usr/bin/node
ln -sf ${NODEJS_FOLDER}/node-v*-${NODEJS_DISTRO}/bin/npm   /usr/bin/npm
ln -sf ${NODEJS_FOLDER}/node-v*-${NODEJS_DISTRO}/bin/npx   /usr/bin/npx

npm install --global npm
npm install --global yarn
npm install --global @angular/cli
npm install --global react-cli
npm install --global typescript

ln -sf ${NODEJS_FOLDER}/node-v*-${NODEJS_DISTRO}/bin/yarn       /usr/bin/yarn
ln -sf ${NODEJS_FOLDER}/node-v*-${NODEJS_DISTRO}/bin/ng         /usr/bin/ng
ln -sf ${NODEJS_FOLDER}/node-v*-${NODEJS_DISTRO}/bin/react-cli  /usr/bin/react
ln -sf ${NODEJS_FOLDER}/node-v*-${NODEJS_DISTRO}/bin/tsc        /usr/bin/tsc

echo -e "\nDone...\n"
