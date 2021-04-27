#!/usr/bin/env bash

ERROR_COLOR='\033[7;31m'
TITLE_COLOR='\033[1;31m'
NC='\033[0m'

NODEJS_VERSION="v14.16.0"
NODEJS_DISTRO="linux-x64"
NODEJS_URL="https://nodejs.org/dist/${NODEJS_VERSION}/node-${NODEJS_VERSION}-${NODEJS_DISTRO}.tar.xz"

if [ $(id -u) != 0 ]; then
  echo -e "${ERROR_COLOR}O script deve ser executado como root${NC}"
  exit
fi

echo -e "\n${TITLE_COLOR}Instalando NodeJS${NC}"

if [ -d /opt/nodejs/node-${NODEJS_VERSION}-${NODEJS_DISTRO} ]; then
  echo -e "Node ${NODEJS_VERSION} já instalado"
else
    if ! [ -f /tmp/node-${NODEJS_VERSION}-${NODEJS_DISTRO}.tar.xz ]; then
        wget -q ${NODEJS_URL} --show-progress -P /tmp/
    fi

    mkdir -p /opt/nodejs
    tar xf /tmp/node-${NODEJS_VERSION}-${NODEJS_DISTRO}.tar.xz --directory /opt/nodejs
    
    ln -sf /opt/nodejs/node-v*-linux-x64/bin/node  /usr/bin/node
    ln -sf /opt/nodejs/node-v*-linux-x64/bin/npm   /usr/bin/npm
    ln -sf /opt/nodejs/node-v*-linux-x64/bin/npx   /usr/bin/npx

    npm install --global yarn
    npm install --global @angular/cli
    npm install --global react-cli

    ln -sf /opt/nodejs/node-v*-linux-x64/bin/yarn  /usr/bin/yarn
    ln -sf /opt/nodejs/node-v*-linux-x64/bin/ng    /usr/bin/ng
    ln -sf /opt/nodejs/node-v*-linux-x64/bin/react-cli /usr/bin/react
fi

echo -e "\nDone...\n"
