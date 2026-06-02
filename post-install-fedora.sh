#!/bin/bash
set -euo pipefail

BLUE='\033[0;34m'
NC='\033[0m'

INSTALADOS=()
PULADOS=()
FALHOS=()
PROGRESS_PIPE=$(mktemp -u)
ZENITY_PROGRESS_PID=""
SUDO_KEEPALIVE_PID=""
MONITOR_PID=""

cleanup() {
    [[ -n "${SUDO_KEEPALIVE_PID:-}" ]] && kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
    { echo "100" >&4; exec 4>&-; } 2>/dev/null || true
    [[ -n "${ZENITY_PROGRESS_PID:-}" ]] && kill "$ZENITY_PROGRESS_PID" 2>/dev/null || true
    rm -f "$PROGRESS_PIPE" 2>/dev/null || true
}
trap cleanup EXIT
trap 'trap - SIGTERM; kill -- -$$ 2>/dev/null; exit 1' SIGTERM

echo -e "${BLUE}=== Fedora 44 Workstation — Script de Pós-Instalação ===${NC}"

# Verifica zenity
if ! command -v zenity &>/dev/null; then
    echo -e "${BLUE}Instalando zenity...${NC}"
    sudo dnf install zenity -y
fi

# Sudo
if ! sudo -v; then
    echo -e "${BLUE}Permissão sudo é necessária para executar este script.${NC}"
    exit 1
fi

while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
SUDO_KEEPALIVE_PID=$!

cancelar() {
    echo "Cancelado."
    exit 0
}

# --- Seleção ---
n_itens=25
altura=$(( 140 + n_itens * 36 ))

SELECTED=$(zenity --list --checklist \
    --title="Fedora 44 — Pós-Instalação" \
    --text="Selecione o que deseja instalar e configurar:" \
    --column="" --column="ID" --column="Descrição" \
    --width=620 --height="$altura" \
    --ok-label="Instalar" \
    --cancel-label="Desistir" \
    --hide-column=2 \
    --hide-header \
    --separator="|" \
    TRUE  dnf5        "Otimizar o DNF5 (velocidade e cores)  [DNF]" \
    TRUE  sysupdate   "Atualizar sistema  [DNF]" \
    TRUE  rpmfusion   "Habilitar RPM Fusion  [DNF]" \
    TRUE  flathub     "Habilitar Flathub  [Flatpak]" \
    TRUE  firmware    "Atualizar firmware do hardware  [fwupd]" \
    TRUE  codecs      "Codecs de hardware para GPU  [RPM Fusion]" \
    TRUE  chrome      "Google Chrome  [RPM]" \
    TRUE  1password   "1Password  [RPM]" \
    TRUE  neovim      "Neovim  [DNF]" \
    TRUE  vscode      "Visual Studio Code  [RPM]" \
    TRUE  toolbox     "JetBrains Toolbox  [tarball]" \
    TRUE  tweaks      "GNOME Tweaks  [DNF]" \
    TRUE  extmgr      "Gerenciador de Extensões GNOME  [DNF]" \
    TRUE  discord     "Discord  [Flatpak]" \
    TRUE  spotify     "Spotify  [Flatpak]" \
    TRUE  flatseal    "Flatseal  [Flatpak]" \
    TRUE  temas       "Temas e ícones (Yaru-dark e Breeze cursor)  [DNF]" \
    TRUE  fontes      "Fonte JetBrains Mono Nerd Font  [download]" \
    TRUE  gnome       "Configurações de interface do GNOME  [gsettings]" \
    TRUE  fish        "Fish Shell (padrão + plugins)  [DNF]" \
    TRUE  clitools    "Ferramentas CLI (bat, eza, bottom)  [DNF]" \
    TRUE  claudecode  "Claude Code  [Node.js]" \
    TRUE  codex       "Codex (OpenAI)  [Node.js]" \
    TRUE  limpeza     "Limpeza do sistema (autoremove)  [DNF]" \
    TRUE  hostname    "Definir hostname da máquina  [sistema]" \
    2>/dev/null) || cancelar

if [[ -z "$SELECTED" ]]; then
    zenity --info --title="Nada selecionado" \
        --text="Nenhuma opção foi selecionada. Encerrando." \
        --width=300 2>/dev/null || true
    exit 0
fi

run_section() {
    echo "$SELECTED" | tr '|' '\n' | grep -qx "$1"
}

flathub_ok() {
    flatpak remotes 2>/dev/null | grep -q flathub
}

npm_setup() {
    if ! command -v node &>/dev/null; then
        echo -e "${BLUE}Instalando Node.js...${NC}"
        sudo dnf install nodejs npm -y
    fi
    local NPM_PREFIX="$HOME/.npm-global"
    if [[ "$(npm config get prefix 2>/dev/null)" != "$NPM_PREFIX" ]]; then
        mkdir -p "$NPM_PREFIX"
        npm config set prefix "$NPM_PREFIX"
    fi
    export PATH="$NPM_PREFIX/bin:$PATH"
    grep -q 'npm-global' ~/.bashrc 2>/dev/null || \
        echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc
    if command -v fish &>/dev/null; then
        fish -c "contains $HOME/.npm-global/bin \$fish_user_paths
            or set -U fish_user_paths $HOME/.npm-global/bin \$fish_user_paths" 2>/dev/null || true
    fi
}

# --- Barra de progresso ---
TOTAL_STEPS=$(echo "$SELECTED" | tr '|' '\n' | grep -c . 2>/dev/null || echo 1)
STEP=0

mkfifo "$PROGRESS_PIPE"
zenity --progress \
    --title="Fedora 44 — Instalando" \
    --text="Iniciando instalação..." \
    --percentage=0 \
    --width=500 \
    --auto-close \
    2>/dev/null < "$PROGRESS_PIPE" &
ZENITY_PROGRESS_PID=$!
exec 4>"$PROGRESS_PIPE"

# Encerra o script se o usuário cancelar pela janela do zenity
( while kill -0 "$ZENITY_PROGRESS_PID" 2>/dev/null; do sleep 1; done
  kill -TERM -$$ 2>/dev/null ) &
MONITOR_PID=$!

progresso() {
    STEP=$(( STEP + 1 ))
    local pct=$(( STEP * 100 / TOTAL_STEPS ))
    { echo "# [$pct%] $1"; echo "$pct"; } >&4 2>/dev/null || true
    echo -e "${BLUE}$1${NC}"
}

# --- Execução ---

if run_section dnf5; then
    progresso "Otimizando DNF5..."
    grep -q 'max_parallel_downloads=10' /etc/dnf/dnf.conf || echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf
    grep -q 'colors=always' /etc/dnf/dnf.conf || echo 'colors=always' | sudo tee -a /etc/dnf/dnf.conf
    INSTALADOS+=("DNF5 otimizado")
fi

if run_section sysupdate; then
    progresso "Atualizando sistema..."
    sudo dnf upgrade --refresh -y
    sudo dnf group upgrade core -y
    INSTALADOS+=("Sistema atualizado")
fi

if run_section rpmfusion; then
    progresso "Habilitando RPM Fusion..."
    if ! rpm -q rpmfusion-free-release &>/dev/null; then
        sudo dnf install \
            "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm" \
            "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm" -y \
            && INSTALADOS+=("RPM Fusion") || FALHOS+=("RPM Fusion")
    else
        PULADOS+=("RPM Fusion")
    fi
fi

if run_section flathub; then
    progresso "Habilitando Flathub..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak remote-modify --enable flathub
    INSTALADOS+=("Flathub")
fi

if run_section firmware; then
    progresso "Atualizando firmware..."
    sudo fwupdmgr refresh --force
    sudo fwupdmgr update || true
    INSTALADOS+=("Firmware atualizado")
fi

if run_section codecs; then
    progresso "Instalando codecs de GPU..."
    if ! rpm -q rpmfusion-nonfree-release &>/dev/null; then
        echo -e "${BLUE}RPM Fusion nonfree não encontrado — habilite o RPM Fusion primeiro.${NC}"
        FALHOS+=("Codecs GPU (RPM Fusion ausente)")
    else
        codec_ok=true
        if ! rpm -q mesa-va-drivers-freeworld &>/dev/null; then
            sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld -y 2>&1 || codec_ok=false
        fi
        if ! rpm -q mesa-vdpau-drivers-freeworld &>/dev/null; then
            sudo dnf swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld -y 2>&1 || true
        fi
        $codec_ok && INSTALADOS+=("Codecs GPU") || FALHOS+=("Codecs GPU (falhou parcialmente)")
    fi
fi

if run_section chrome; then
    progresso "Instalando Google Chrome..."
    if ! rpm -q google-chrome-stable &>/dev/null; then
        sudo dnf install https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm -y --disablerepo='*' && INSTALADOS+=("Google Chrome") || FALHOS+=("Google Chrome")
    else
        PULADOS+=("Google Chrome")
    fi
fi

if run_section 1password; then
    progresso "Instalando 1Password..."
    if ! rpm -q 1password &>/dev/null; then
        sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
        printf '[1password]\nname=1Password\nbaseurl=https://downloads.1password.com/linux/rpm/stable/$basearch\nenabled=1\ngpgcheck=1\ngpgkey=https://downloads.1password.com/linux/keys/1password.asc\n' \
            | sudo tee /etc/yum.repos.d/1password.repo
        sudo dnf install 1password -y && INSTALADOS+=("1Password") || FALHOS+=("1Password")
    else
        PULADOS+=("1Password")
    fi
fi

if run_section neovim; then
    progresso "Instalando Neovim..."
    sudo dnf install neovim -y && INSTALADOS+=("Neovim") || FALHOS+=("Neovim")
fi

if run_section vscode; then
    progresso "Instalando VS Code..."
    if ! rpm -q code &>/dev/null; then
        sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
        printf '[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc\n' \
            | sudo tee /etc/yum.repos.d/vscode.repo
        sudo dnf install code -y --disablerepo='*' --enablerepo='code' && INSTALADOS+=("VS Code") || FALHOS+=("VS Code")
    else
        PULADOS+=("VS Code")
    fi
fi

if run_section toolbox; then
    progresso "Instalando JetBrains Toolbox..."
    if [[ ! -f ~/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox ]]; then
        URL=$(curl -s "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release" \
            | python3 -c "import sys,json; print(json.load(sys.stdin)['TBA'][0]['downloads']['linux']['link'])")
        curl -fLo /tmp/jetbrains-toolbox.tar.gz "$URL"
        TOOLBOX_DIR=$(tar -tzf /tmp/jetbrains-toolbox.tar.gz | head -1 | cut -d/ -f1)
        tar -xzf /tmp/jetbrains-toolbox.tar.gz -C /tmp
        mkdir -p ~/.local/share/JetBrains/Toolbox/bin
        mv "/tmp/$TOOLBOX_DIR/jetbrains-toolbox" ~/.local/share/JetBrains/Toolbox/bin/
        chmod +x ~/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox
        ~/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox &
        INSTALADOS+=("JetBrains Toolbox")
    else
        PULADOS+=("JetBrains Toolbox")
    fi
fi

if run_section tweaks; then
    progresso "Instalando GNOME Tweaks..."
    sudo dnf install gnome-tweaks -y && INSTALADOS+=("GNOME Tweaks") || FALHOS+=("GNOME Tweaks")
fi

if run_section extmgr; then
    progresso "Instalando Gerenciador de Extensões..."
    sudo dnf install gnome-extensions-app -y && INSTALADOS+=("Gerenciador de Extensões") || FALHOS+=("Gerenciador de Extensões")
fi

if run_section discord; then
    progresso "Instalando Discord..."
    if flathub_ok; then
        flatpak install --or-update flathub com.discordapp.Discord -y && INSTALADOS+=("Discord") || FALHOS+=("Discord")
    else
        echo -e "${BLUE}Flathub não habilitado — pulando Discord.${NC}"
        FALHOS+=("Discord (Flathub ausente)")
    fi
fi

if run_section spotify; then
    progresso "Instalando Spotify..."
    if flathub_ok; then
        flatpak install --or-update flathub com.spotify.Client -y && INSTALADOS+=("Spotify") || FALHOS+=("Spotify")
    else
        echo -e "${BLUE}Flathub não habilitado — pulando Spotify.${NC}"
        FALHOS+=("Spotify (Flathub ausente)")
    fi
fi

if run_section flatseal; then
    progresso "Instalando Flatseal..."
    if flathub_ok; then
        flatpak install --or-update flathub com.github.tchx84.Flatseal -y && INSTALADOS+=("Flatseal") || FALHOS+=("Flatseal")
    else
        echo -e "${BLUE}Flathub não habilitado — pulando Flatseal.${NC}"
        FALHOS+=("Flatseal (Flathub ausente)")
    fi
fi

if run_section temas; then
    progresso "Instalando temas e ícones..."
    sudo dnf install breeze-cursor-theme yaru-icon-theme -y && INSTALADOS+=("Temas e ícones") || FALHOS+=("Temas e ícones")
fi

if run_section fontes; then
    progresso "Instalando JetBrains Mono Nerd Font..."
    if [[ ! -f ~/.local/share/fonts/JetBrainsMonoNerdFont-Regular.ttf ]]; then
        sudo dnf install -y unzip
        mkdir -p ~/.local/share/fonts
        curl -fLo "/tmp/JetBrainsMono.zip" \
            https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
        unzip -t /tmp/JetBrainsMono.zip > /dev/null
        unzip -oq /tmp/JetBrainsMono.zip -d ~/.local/share/fonts
        fc-cache -f
        INSTALADOS+=("JetBrains Mono Nerd Font")
    else
        PULADOS+=("JetBrains Mono Nerd Font")
    fi
fi

if run_section gnome; then
    progresso "Aplicando configurações do GNOME..."
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    gsettings set org.gnome.desktop.interface icon-theme 'Yaru-dark'
    gsettings set org.gnome.desktop.interface cursor-theme 'Breeze_cursors'
    gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
    gsettings set org.gnome.desktop.interface show-battery-percentage true
    gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
    gsettings set org.gnome.nautilus.preferences default-sort-order 'type' || true
    if [[ -f ~/.local/share/fonts/JetBrainsMonoNerdFont-Regular.ttf ]]; then
        gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 10'
    else
        echo -e "${BLUE}JetBrains Mono não encontrada — fonte monoespaçada não configurada.${NC}"
    fi
    INSTALADOS+=("Configurações GNOME")
fi

if run_section fish; then
    progresso "Instalando Fish Shell..."
    sudo dnf install -y fish
    hash -r
    if [[ "$(getent passwd "$(whoami)" | cut -d: -f7)" != "$(which fish)" ]]; then
        chsh -s "$(which fish)"
    fi
    fish -c "functions -q fisher
        or begin
            curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
            and fisher install jorgebucaran/fisher
        end"
    fish -c "fisher list 2>/dev/null | grep -q plugin-git; or fisher install jhillyerd/plugin-git"
    fish -c "fisher list 2>/dev/null | grep -q fish-abbreviation-tips; or fisher install gazorby/fish-abbreviation-tips"
    fish -c "fisher list 2>/dev/null | grep -q tide; or fisher install IlanCosman/tide@v5"
    echo -e "${BLUE}Dica: execute 'tide configure' após reiniciar para configurar o prompt.${NC}"
    INSTALADOS+=("Fish Shell")
fi

if run_section clitools; then
    progresso "Instalando ferramentas CLI..."
    sudo dnf install bat eza bottom -y && INSTALADOS+=("Ferramentas CLI (bat, eza, bottom)") || FALHOS+=("Ferramentas CLI")
fi

if run_section claudecode || run_section codex; then
    npm_setup
fi

if run_section claudecode; then
    progresso "Instalando Claude Code..."
    if ! command -v claude &>/dev/null; then
        npm install -g @anthropic-ai/claude-code && INSTALADOS+=("Claude Code") || FALHOS+=("Claude Code")
    else
        PULADOS+=("Claude Code")
    fi
fi

if run_section codex; then
    progresso "Instalando Codex (OpenAI)..."
    if ! command -v codex &>/dev/null; then
        npm install -g @openai/codex && INSTALADOS+=("Codex (OpenAI)") || FALHOS+=("Codex (OpenAI)")
    else
        PULADOS+=("Codex (OpenAI)")
    fi
fi

if run_section limpeza; then
    progresso "Limpando sistema..."
    sudo dnf autoremove -y
    sudo dnf clean all
    INSTALADOS+=("Limpeza concluída")
fi

# Fecha a barra de progresso
[[ -n "${MONITOR_PID:-}" ]] && kill "$MONITOR_PID" 2>/dev/null || true
{ echo "100"; } >&4 2>/dev/null || true
exec 4>&- 2>/dev/null || true
wait "$ZENITY_PROGRESS_PID" 2>/dev/null || true
ZENITY_PROGRESS_PID=""

# Hostname
if run_section hostname; then
    new_hostname=$(zenity --entry --title="Hostname" --text="Digite o novo hostname:" 2>/dev/null) || true
    if [[ -n "$new_hostname" ]]; then
        sudo hostnamectl set-hostname "$new_hostname"
        INSTALADOS+=("Hostname: $new_hostname")
    fi
fi

# --- Resumo ---
build_list() {
    local prefix="$1"; shift
    local out=""
    for item in "$@"; do
        out+="$prefix $item\n"
    done
    echo -e "$out"
}

MSG=""
[[ ${#INSTALADOS[@]} -gt 0 ]] && MSG+="Instalados:\n$(build_list "✓" "${INSTALADOS[@]}")\n"
[[ ${#PULADOS[@]} -gt 0 ]]   && MSG+="Já instalados (pulados):\n$(build_list "→" "${PULADOS[@]}")\n"
[[ ${#FALHOS[@]} -gt 0 ]]    && MSG+="Com problemas:\n$(build_list "✗" "${FALHOS[@]}")\n"
MSG+="Reinicie o sistema para aplicar todas as mudanças."

zenity --info \
    --title="Fedora 44 — Concluído" \
    --text="$MSG" \
    --width=480 \
    2>/dev/null || true

echo -e "\n${BLUE}Script finalizado! Por favor, REINICIE o sistema.${NC}"
