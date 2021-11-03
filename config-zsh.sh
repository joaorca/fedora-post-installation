#!/usr/bin/env bash

TITLE_COLOR='\033[1;31m'
NC='\033[0m'

URL_OHMYZSH_REPOSITORY="https://github.com/robbyrussell/oh-my-zsh.git"
URL_SPACESHIP_REPOSITORY="https://github.com/denysdovhan/spaceship-prompt.git"
OHMYZSH_THEME_PATH="$HOME/.oh-my-zsh/custom/themes"

echo -e "\n${TITLE_COLOR}Limpando dados de configurações pré-existentes${NC}"
rm -rf ~/.oh-my-zsh ~/.zshrc ~/.zinit

echo -e "\n${TITLE_COLOR}Clonando repositório OhMyZSH${NC}"
git clone --quiet $URL_OHMYZSH_REPOSITORY ~/.oh-my-zsh
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

echo -e "\n${TITLE_COLOR}Clonando repositório Spaceship Theme${NC}"
git clone --quiet $URL_SPACESHIP_REPOSITORY $OHMYZSH_THEME_PATH/spaceship-prompt
ln -s $OHMYZSH_THEME_PATH/spaceship-prompt/spaceship.zsh-theme $OHMYZSH_THEME_PATH/spaceship.zsh-theme

echo -e "\n${TITLE_COLOR}Instalando plugin ZPlugin${NC}"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/zdharma-continuum/zinit/master/doc/install.sh)"

echo -e "\n${TITLE_COLOR}Alterando ZSH THEME${NC}"
sed -i 's/^ZSH_THEME=.*/ZSH_THEME=\"spaceship\"/g' ~/.zshrc 
 
echo -e "\n${TITLE_COLOR}Setando configurações do tema${NC}"
echo '
SPACESHIP_PROMPT_ORDER=(user dir host git exec_time line_sep vi_mode jobs exit_code char)
SPACESHIP_USER_SHOW=always
SPACESHIP_PROMPT_ADD_NEWLINE=false
#SPACESHIP_CHAR_SYMBOL="❯"
SPACESHIP_CHAR_SYMBOLSPACESHIP_CHAR_SYMBOL=" "
SPACESHIP_CHAR_SUFFIX=" " ' >> ~/.zshrc  
  
echo -e "\n${TITLE_COLOR}Ativando plugins ZINIT${NC}"
echo ' 
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light zdharma-continuum/fast-syntax-highlighting' >> ~/.zshrc

echo -e "\n${TITLE_COLOR}Ativando plugins${NC}"
sed -i 's/plugins=(.*/plugins=(git extract sudo docker docker-compose composer)/g' ~/.zshrc

#echo -e "\n${TITLE_COLOR}Definindo ZSH como yerminal padrão${NC}"
#chsh -s /bin/zsh

echo -e "\n${TITLE_COLOR}Configuração concluída...${NC}"
zsh
