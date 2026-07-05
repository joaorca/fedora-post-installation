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
SCRIPT_PGID=$(ps -o pgid= -p $$ | tr -d ' ')

cleanup() {
    [[ -n "${MONITOR_PID:-}" ]] && kill "$MONITOR_PID" 2>/dev/null || true
    [[ -n "${SUDO_KEEPALIVE_PID:-}" ]] && kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
    { echo "100" >&4; exec 4>&-; } 2>/dev/null || true
    [[ -n "${ZENITY_PROGRESS_PID:-}" ]] && kill "$ZENITY_PROGRESS_PID" 2>/dev/null || true
    rm -f "$PROGRESS_PIPE" 2>/dev/null || true
}
trap cleanup EXIT
trap 'trap - SIGTERM; kill -- -"$SCRIPT_PGID" 2>/dev/null; exit 1' SIGTERM

echo -e "${BLUE}=== Fedora 44 Workstation — Script de Pós-Instalação ===${NC}"

# Bloqueia execução direta como root
if [[ "$EUID" -eq 0 ]]; then
    echo -e "${BLUE}Erro: não execute este script como root ou com sudo.${NC}"
    echo -e "${BLUE}Execute normalmente: bash post-install-fedora.sh${NC}"
    exit 1
fi

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
_ITEMS=(
    "dnf5|Otimizar o DNF5 (velocidade e cores)  [DNF]"
    "wifi|Desabilitar WiFi power save (reduz latência)  [NetworkManager]"
    "bluetooth|Ativar Bluetooth automático no boot (AutoEnable + FastConnectable)  [bluetoothd]"
    "sysupdate|Atualizar sistema  [DNF]"
    "rpmfusion|Habilitar RPM Fusion  [DNF]"
    "flathub|Habilitar Flathub  [Flatpak]"
    "firmware|Atualizar firmware do hardware  [fwupd]"
    "chrome|Google Chrome  [RPM]"
    "1password|1Password  [RPM]"
    "neovim|Neovim  [DNF]"
    "vscode|Visual Studio Code  [RPM]"
    "toolbox|JetBrains Toolbox  [tarball]"
    "tweaks|GNOME Tweaks  [DNF]"
    "extmgr|Gerenciador de Extensões GNOME  [DNF]"
    "extensions|Extensões GNOME (5 extensões)  [GNOME Extensions]"
    "discord|Discord  [RPM]"
    "spotify|Spotify  [Flatpak]"
    "temas|Temas e ícones (Yaru-dark e Breeze cursor)  [DNF]"
    "fontes|Fonte JetBrains Mono Nerd Font  [download]"
    "gnome|Configurações de interface do GNOME  [gsettings]"
    "fish|Fish Shell (padrão + plugins)  [DNF]"
    "clitools|Ferramentas CLI (bat, eza, btop)  [DNF]"
    "podman|Podman (Docker compat + rootless + socket)  [systemd]"
    "claudecode|Claude Code  [Node.js]"
    "codex|Codex (OpenAI)  [Node.js]"
    "manutencao|Manutenção completa (Flatpak + extensões + limpeza)  [multi]"
    "limpeza|Limpeza do sistema (autoremove)  [DNF]"
    "hostname|Definir hostname da máquina  [sistema]"
    "mx2s|MX Anywhere 2S — botões laterais (workspace)  [input-remapper]"
    "mx3s|MX Anywhere 3S — botões laterais (workspace) + swap middle/smartshift  [input-remapper + Solaar]"
)
n_itens=${#_ITEMS[@]}
altura=$(( 140 + n_itens * 36 ))
_default=TRUE

while true; do
    _args=()
    for _item in "${_ITEMS[@]}"; do
        _id="${_item%%|*}"
        _desc="${_item##*|}"
        _args+=("$_default" "$_id" "$_desc")
    done
    [[ "$_default" == TRUE ]] && _btn="Desmarcar tudo" || _btn="Marcar tudo"

    _result=$(zenity --list --checklist \
        --title="Fedora 44 — Pós-Instalação" \
        --text="Selecione o que deseja instalar e configurar:" \
        --column="" --column="ID" --column="Descrição" \
        --width=620 --height="$altura" \
        --ok-label="Instalar" \
        --cancel-label="Cancelar" \
        --extra-button="$_btn" \
        --hide-column=2 \
        --hide-header \
        --separator="|" \
        "${_args[@]}" \
        2>/dev/null) || true

    case "$_result" in
        "Marcar tudo")   _default=TRUE;  continue ;;
        "Desmarcar tudo") _default=FALSE; continue ;;
        "")
            zenity --info --title="Nada selecionado" \
                --text="Nenhuma opção foi selecionada. Encerrando." \
                --width=300 2>/dev/null || true
            exit 0
            ;;
        *) SELECTED="$_result"; break ;;
    esac
done


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
    local NPM_PREFIX="$HOME/.local"
    if [[ "$(npm config get prefix 2>/dev/null)" != "$NPM_PREFIX" ]]; then
        npm config set prefix "$NPM_PREFIX"
    fi
    local NPM_CACHE="$HOME/.cache/npm"
    if [[ "$(npm config get cache 2>/dev/null)" != "$NPM_CACHE" ]]; then
        mkdir -p "$NPM_CACHE"
        npm config set cache "$NPM_CACHE"
    fi
    if command -v fish &>/dev/null; then
        fish -c "contains -- $HOME/.local/bin \$fish_user_paths; or set -U fish_user_paths $HOME/.local/bin \$fish_user_paths" 2>/dev/null || true
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
    [[ $pct -ge 100 ]] && pct=99
    { echo "# [$pct%] $1"; echo "$pct"; } >&4 2>/dev/null || true
    echo -e "${BLUE}[Etapa $STEP/$TOTAL_STEPS] $1${NC}"
}

# --- Execução ---

if run_section dnf5; then
    progresso "Otimizando DNF5..."
    grep -q 'max_parallel_downloads=10' /etc/dnf/dnf.conf || echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf
    grep -q 'colors=always' /etc/dnf/dnf.conf || echo 'colors=always' | sudo tee -a /etc/dnf/dnf.conf
    INSTALADOS+=("DNF5 otimizado")
fi

if run_section wifi; then
    progresso "Desabilitando WiFi power save..."
    if nmcli -t -f DEVICE,TYPE dev 2>/dev/null | grep -q ':wifi'; then
        sudo tee /etc/NetworkManager/conf.d/wifi-powersave-off.conf > /dev/null << 'NMEOF'
[connection]
wifi.powersave = 2
NMEOF
        WIFI_DEV=$(nmcli -t -f DEVICE,TYPE dev | grep ':wifi' | cut -d: -f1 | head -1)
        iw dev "$WIFI_DEV" set power_save off 2>/dev/null || true
        INSTALADOS+=("WiFi power save desabilitado")
    else
        PULADOS+=("WiFi power save (sem adaptador WiFi detectado)")
    fi
fi

if run_section bluetooth; then
    progresso "Configurando Bluetooth automático..."
    sudo sed -i 's/^#AutoEnable=true/AutoEnable=true/' /etc/bluetooth/main.conf
    sudo sed -i 's/^#FastConnectable = false/FastConnectable = true/' /etc/bluetooth/main.conf
    sudo systemctl restart bluetooth
    INSTALADOS+=("Bluetooth: AutoEnable + FastConnectable")
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
    flatpak update --appstream -y 2>/dev/null || true
    INSTALADOS+=("Flathub")
fi

if run_section firmware; then
    progresso "Atualizando firmware..."
    sudo fwupdmgr refresh --force
    sudo fwupdmgr update || true
    INSTALADOS+=("Firmware atualizado")
fi


if run_section chrome; then
    progresso "Instalando Google Chrome..."
    if ! rpm -q google-chrome-stable &>/dev/null; then
        sudo dnf install https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm -y && INSTALADOS+=("Google Chrome") || FALHOS+=("Google Chrome")
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
            | python3 -c "import sys,json; print(json.load(sys.stdin)['TBA'][0]['downloads']['linux']['link'])" 2>/dev/null || true)
        if [[ -z "$URL" ]]; then
            echo -e "${BLUE}JetBrains Toolbox: não foi possível obter URL de download.${NC}"
            FALHOS+=("JetBrains Toolbox")
        else
            _tb_ok=false
            if curl -fLo /tmp/jetbrains-toolbox.tar.gz "$URL" \
                && tar -xzf /tmp/jetbrains-toolbox.tar.gz -C /tmp; then
                TOOLBOX_DIR=""
                for _d in /tmp/jetbrains-toolbox-*/; do
                    [[ -d "$_d" ]] && TOOLBOX_DIR=$(basename "$_d") && break
                done || true
                if [[ -n "$TOOLBOX_DIR" ]] \
                    && mkdir -p ~/.local/share/JetBrains/Toolbox/bin \
                    && cp -r "/tmp/$TOOLBOX_DIR/bin/." ~/.local/share/JetBrains/Toolbox/bin/ \
                    && chmod +x ~/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox; then
                    _tb_ok=true
                else
                    echo -e "${BLUE}JetBrains Toolbox: falha ao copiar (TOOLBOX_DIR='$TOOLBOX_DIR').${NC}"
                fi
            else
                echo -e "${BLUE}JetBrains Toolbox: falha no download ou extração.${NC}"
            fi
            if $_tb_ok; then
                ~/.local/share/JetBrains/Toolbox/bin/jetbrains-toolbox &
                INSTALADOS+=("JetBrains Toolbox")
            else
                FALHOS+=("JetBrains Toolbox")
            fi
        fi
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

GNOME_EXTENSIONS=(
    "615"   # AppIndicator and KStatusNotifierItem Support
    "1401"  # Bluetooth Quick Connect
    "3843"  # Just Perfection
    "1460"  # Vitals
    "517"   # Caffeine
)

if run_section extensions; then
    progresso "Instalando extensões GNOME (${#GNOME_EXTENSIONS[@]} extensões)..."
    if ! command -v gext &>/dev/null; then
        if ! python3 -m pip show gnome-extensions-cli &>/dev/null; then
            sudo dnf install python3-pip -y 2>/dev/null || true
            python3 -m pip install --user gnome-extensions-cli
        fi
    fi
    GEXT="${HOME}/.local/bin/gext"
    ext_ok=true
    for ext_id in "${GNOME_EXTENSIONS[@]}"; do
        "$GEXT" install "$ext_id" 2>/dev/null && "$GEXT" enable "$ext_id" 2>/dev/null || ext_ok=false
    done
    $ext_ok && INSTALADOS+=("Extensões GNOME (${#GNOME_EXTENSIONS[@]})") || FALHOS+=("Extensões GNOME (falha parcial)")
fi

if run_section discord; then
    progresso "Instalando Discord..."
    if ! rpm -q discord &>/dev/null; then
        sudo dnf install "https://discord.com/api/download?platform=linux&format=rpm" -y \
            && INSTALADOS+=("Discord") || FALHOS+=("Discord")
    else
        PULADOS+=("Discord")
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
    gsettings set org.gnome.desktop.interface cursor-theme 'breeze_cursors'
    gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
    gsettings set org.gnome.desktop.interface show-battery-percentage true
    gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
    # Nautilus
    gsettings set org.gnome.nautilus.preferences default-sort-order 'type' || true
    gsettings set org.gnome.nautilus.preferences show-hidden-files true || true
    gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view' || true
    # Clock
    gsettings set org.gnome.desktop.interface clock-show-weekday true
    gsettings set org.gnome.desktop.interface clock-show-date true
    gsettings set org.gnome.desktop.interface clock-format '24h'
    gsettings set org.gnome.desktop.datetime automatic-timezone true
    gsettings set org.gnome.desktop.interface enable-hot-corners false
    # Keybindings: Alt+Tab = apps agrupados, Super+Tab = janelas individuais
    gsettings set org.gnome.desktop.wm.keybindings switch-applications "['<Alt>Tab']"
    gsettings set org.gnome.desktop.wm.keybindings switch-applications-backward "['<Shift><Alt>Tab']"
    gsettings set org.gnome.desktop.wm.keybindings switch-windows "['<Super>Tab']"
    gsettings set org.gnome.desktop.wm.keybindings switch-windows-backward "['<Shift><Super>Tab']"
    # Power profile: performance (via tuned)
    sudo tuned-adm profile throughput-performance 2>/dev/null || true
    # Fontes — antialiasing e hinting
    gsettings set org.gnome.desktop.interface font-antialiasing 'rgba'
    gsettings set org.gnome.desktop.interface font-hinting 'slight'
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
    fish -c "fisher list 2>/dev/null | grep -q fish-eza; or fisher install givensuman/fish-eza"
    echo -e "${BLUE}Dica: execute 'tide configure' após reiniciar para configurar o prompt.${NC}"
    INSTALADOS+=("Fish Shell")
fi

if run_section clitools; then
    progresso "Instalando ferramentas CLI..."
    sudo dnf install bat eza btop -y --skip-unavailable && INSTALADOS+=("Ferramentas CLI (bat, eza, btop)") || FALHOS+=("Ferramentas CLI")
fi

if run_section podman; then
    progresso "Configurando Podman..."
    # podman-docker: fornece o comando 'docker' apontando para podman
    if ! rpm -q podman-docker &>/dev/null; then
        sudo dnf install podman-docker podman-compose -y && INSTALADOS+=("podman-docker + podman-compose") || FALHOS+=("podman-docker")
    else
        PULADOS+=("podman-docker")
    fi
    # Socket Podman: compatibilidade com ferramentas que usam Docker API
    systemctl --user enable --now podman.socket 2>/dev/null && INSTALADOS+=("Podman socket") || true
    # Linger: containers rootless rodam sem sessão ativa
    loginctl enable-linger "$(whoami)" 2>/dev/null && INSTALADOS+=("Podman linger") || true
    INSTALADOS+=("Podman configurado")
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

if run_section manutencao; then
    progresso "Executando manutenção completa do sistema..."
    # Flatpaks
    echo -e "${BLUE}Atualizando Flatpaks...${NC}"
    flatpak update -y 2>&1 | tail -3
    # Extensões GNOME
    if command -v gext &>/dev/null || [[ -f "$HOME/.local/bin/gext" ]]; then
        echo -e "${BLUE}Atualizando extensões GNOME...${NC}"
        "${HOME}/.local/bin/gext" upgrade 2>/dev/null || true
        python3 -m pip install --user --upgrade gnome-extensions-cli 2>/dev/null || true
    fi
    # DNF
    echo -e "${BLUE}Atualizando pacotes DNF...${NC}"
    sudo dnf upgrade --refresh -y 2>&1 | tail -5
    # Limpeza
    sudo dnf autoremove -y 2>/dev/null || true
    sudo dnf clean all 2>/dev/null || true
    INSTALADOS+=("Manutenção completa")
fi

if run_section limpeza; then
    progresso "Limpando sistema..."
    sudo dnf autoremove -y
    sudo dnf clean all
    INSTALADOS+=("Limpeza concluída")
fi

# Fecha a barra de progresso
[[ -n "${MONITOR_PID:-}" ]] && kill "$MONITOR_PID" 2>/dev/null || true
MONITOR_PID=""
{ echo "100"; } >&4 2>/dev/null || true
exec 4>&- 2>/dev/null || true
wait "$ZENITY_PROGRESS_PID" 2>/dev/null || true
ZENITY_PROGRESS_PID=""

# MX Anywhere 2S — input-remapper (botões laterais → workspace)
_setup_input_remapper() {
    local _mouse_pattern="$1"
    if ! rpm -q input-remapper &>/dev/null; then
        sudo dnf install -y input-remapper || { FALHOS+=("input-remapper"); return 1; }
    fi
    sudo systemctl enable --now input-remapper
    local _config_file="$HOME/.config/input-remapper-2/config.json"
    local _found=0
    while IFS='|' read -r _mouse_name _mouse_hash; do
        [[ -z "$_mouse_hash" ]] && continue
        _found=1
        local _preset_dir="$HOME/.config/input-remapper-2/presets/$_mouse_name"
        mkdir -p "$_preset_dir"
        cat > "$_preset_dir/workspaces.json" << EOF
[
    {
        "input_combination": [{"type": 1, "code": 275, "origin_hash": "$_mouse_hash"}],
        "target_uinput": "keyboard",
        "output_symbol": "KEY_LEFTCTRL + KEY_LEFTALT + KEY_RIGHT",
        "mapping_type": "key_macro",
        "name": "workspace direita"
    },
    {
        "input_combination": [{"type": 1, "code": 276, "origin_hash": "$_mouse_hash"}],
        "target_uinput": "keyboard",
        "output_symbol": "KEY_LEFTCTRL + KEY_LEFTALT + KEY_LEFT",
        "mapping_type": "key_macro",
        "name": "workspace esquerda"
    }
]
EOF
        if [[ -f "$_config_file" ]]; then
            python3 -c "
import json
with open('$_config_file') as f:
    cfg = json.load(f)
cfg.setdefault('autoload', {})['$_mouse_name'] = 'workspaces'
with open('$_config_file', 'w') as f:
    json.dump(cfg, f, indent=4)
" 2>/dev/null
        else
            printf '{\n    "version": "2.2.0",\n    "autoload": {\n        "%s": "workspaces"\n    }\n}\n' "$_mouse_name" > "$_config_file"
        fi
        INSTALADOS+=("input-remapper: $_mouse_name")
    done < <(sudo python3 -c "
import glob
from inputremapper.utils import get_device_hash
import evdev
for path in sorted(glob.glob('/dev/input/event*')):
    try:
        dev = evdev.InputDevice(path)
        if '$_mouse_pattern' in dev.name:
            print(dev.name + '|' + get_device_hash(dev))
    except Exception:
        pass
" 2>/dev/null)
    if [[ $_found -eq 0 ]]; then
        echo -e "${BLUE}Mouse não encontrado — conecte via Bluetooth e rode novamente.${NC}"
        FALHOS+=("input-remapper: $_mouse_pattern não encontrado")
        return 1
    fi
    sudo input-remapper-control --command stop-all 2>/dev/null || true
    sudo input-remapper-control --command autoload 2>/dev/null || true
}

if run_section mx2s; then
    progresso "Configurando MX Anywhere 2S (input-remapper)..."
    _setup_input_remapper "MX Anywhere 2S Mouse"
fi

# MX Anywhere 3S — input-remapper (botões laterais → workspace) + Solaar (swap middle/smartshift)
if run_section mx3s; then
    progresso "Configurando MX Anywhere 3S (input-remapper + Solaar)..."
    _setup_input_remapper "Logitech MX Anywhere 3S"
    # Solaar: swap Middle Button ↔ Smart Shift
    if ! rpm -q solaar &>/dev/null; then
        sudo dnf install -y solaar || { FALHOS+=("solaar"); }
    else
        PULADOS+=("solaar (já instalado)")
    fi
    if rpm -q solaar &>/dev/null; then
        if solaar show 2>/dev/null | grep -q "MX Anywhere 3S"; then
            solaar config "MX Anywhere 3S" reprogrammable-keys "Middle Button" "Smart Shift" 2>/dev/null
            solaar config "MX Anywhere 3S" reprogrammable-keys "Smart Shift" "Mouse Middle Button" 2>/dev/null
            INSTALADOS+=("Solaar: MX Anywhere 3S botões configurados")
        else
            echo -e "${BLUE}MX Anywhere 3S não encontrado via Solaar — conecte via Bluetooth e rode novamente.${NC}"
            FALHOS+=("solaar: MX Anywhere 3S não encontrado")
        fi
    fi
fi

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
