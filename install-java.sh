#!/usr/bin/env bash

ERROR_COLOR='\033[7;31m'
TITLE_COLOR='\033[1;31m'
NC='\033[0m'

JAVA_LINK="https://download.oracle.com/otn-pub/java/jdk/16+36/7863447f0ab643c585b9bdebf67c69db/jdk-16_linux-x64_bin.tar.gz?AuthParam=1616987181_ec5a86e53e14d813b63d10e3e916834f"

if [ $(id -u) != 0 ]; then
  echo -e "${ERROR_COLOR}O script deve ser executado como root${NC}"
  exit
fi

echo -e "\n${TITLE_COLOR}Instalando JAVA${NC}"
wget -q ${JAVA_LINK} --show-progress -O /tmp/java.tar.gz
tar -zxf /tmp/java.tar.gz -C /tmp/
mkdir -p /opt/java-jre
mv /tmp/jre*/* /opt/java-jre
update-alternatives --install /usr/bin/java java /opt/java-jre/bin/java 1
