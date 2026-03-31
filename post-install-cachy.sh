#!/usr/bin/env bash
# Script de pós-instalação adaptado para CachyOS (GNOME)

# --- CORES ---
VERMELHO='\e[1;31m'
VERDE='\e[1;32m'
SEM_COR='\e[0m'

echo -e "${VERDE}Iniciando Pós-Instalação CachyOS...${SEM_COR}"

# 1. Atualização de Mirrors e Sistema
echo -e "${VERDE}Otimizando mirrors e atualizando sistema...${SEM_COR}"
sudo cachyos-rate-mirrors
sudo pacman -Syu --noconfirm

# 2. Instalação de ferramentas essenciais (Equivalente ao build-essential do Ubuntu)
echo -e "${VERDE}Instalando base-devel e ferramentas essenciais...${SEM_COR}"
sudo pacman -S --needed base-devel git wget curl flatpak gnome-tweaks dconf-editor --noconfirm

# 3. Otimização para Intel Core Ultra (O ponto crítico)
echo -e "${VERDE}Configurando otimizações para Intel Core Ultra...${SEM_COR}"
sudo pacman -S --needed intel-ucode thermald libva-intel-driver intel-media-driver --noconfirm
sudo systemctl enable --now thermald

# 4. Multimídia e Codecs
echo -e "${VERDE}Instalando codecs multimídia...${SEM_COR}"
sudo pacman -S --needed gst-libav gst-plugins-bad gst-plugins-ugly libdvdcss vlc --noconfirm

# 5. Suporte a AUR (No CachyOS o 'paru' ou 'yay' geralmente já vêm instalados)
# Se não estiverem, o comando abaixo instala o paru:
if ! command -v paru &> /dev/null; then
    sudo pacman -S --needed paru --noconfirm
fi

# 6. Instalação de Softwares Comuns (Exemplos do seu script anterior)
echo -e "${VERDE}Instalando programas...${SEM_COR}"
# No Arch/Cachy, muitos apps do seu script de Ubuntu estão no repositório oficial
sudo pacman -S --needed discord spotify-launcher steam code --noconfirm

# 7. Configurações do GNOME (Via dconf)
echo -e "${VERDE}Aplicando tweaks no GNOME...${SEM_COR}"
# Habilitar botões de minimizar/maximizar
gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' # Exemplo de tema
gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
# Ativar toque para clicar no touchpad
gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true

# 8. Limpeza de cache
echo -e "${VERDE}Limpando pacotes antigos...${SEM_COR}"
sudo pacman -Sc --noconfirm

echo -e "${VERDE}Pós-instalação finalizada! Recomenda-se reiniciar.${SEM_COR}"
