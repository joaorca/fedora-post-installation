#!/bin/bash

# Terminal Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Fedora 43 Workstation Script (Ultimate Master Version) ===${NC}"

# --- ROOT CHECK & SUDO KEEP-ALIVE ---
if ! sudo -v; then
    echo -e "${BLUE}Sudo permission is required to run this script.${NC}"
    exit 1
fi

# Mantém o sudo ativo em segundo plano
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

echo -e "${GREEN}Sudo session activated. Default option for questions is [Y].${NC}"
# ------------------------------------

ask_task() {
    echo -ne "\n${GREEN}Do you want to $1? [Y/n]: ${NC}"
    read -r response
    # Se a resposta for vazia (Enter) ou começar com y/Y, retorna sucesso (0)
    if [[ -z "$response" || "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        return 0
    else
        return 1
    fi
}

# 1. DNF5 Optimization
if ask_task "optimize DNF5 (Speed & Colors)"; then
    sudo sed -i '/max_parallel_downloads/d' /etc/dnf/dnf.conf
    sudo sed -i '/colors/d' /etc/dnf/dnf.conf
    echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf
    echo 'colors=always' | sudo tee -a /etc/dnf/dnf.conf
fi

# 2. Update & Repositories (RPM Fusion + Flathub)
if ask_task "update system and enable RPM Fusion + Flathub"; then
    sudo dnf upgrade --refresh -y
    sudo dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
                     https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm -y
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak remote-modify --enable flathub
fi

# 3. Apps: Google Chrome, Discord & Flatseal
if ask_task "install Google Chrome, Discord and Flatseal"; then
    sudo dnf install fedora-workstation-repositories -y
    sudo dnf config-manager setopt google-chrome.enabled=1
    sudo dnf install google-chrome-stable -y
    flatpak remote-modify --enable flathub
    flatpak install flathub com.discordapp.Discord com.github.tchx84.Flatseal -y
fi

# 4. Hardware: Firmware & GPU Codecs
if ask_task "update Firmware and install Hardware Codecs"; then
    sudo fwupdmgr refresh --force && sudo fwupdmgr update
    sudo dnf swap mesa-va-drivers mesa-va-drivers-freeworld -y
    sudo dnf swap mesa-vdpau-drivers mesa-vdpau-drivers-freeworld -y
    sudo dnf group upgrade core -y
fi

# 5. Editing, Aesthetics & Nerd Fonts
if ask_task "install Neovim, JetBrains Mono Nerd Font, Yaru-Blue and Breeze Themes"; then
    sudo dnf install neovim breeze-cursor-theme yaru-icon-theme -y
    echo -e "${BLUE}Downloading JetBrains Mono Nerd Font...${NC}"
    mkdir -p ~/.local/share/fonts
    curl -fLo "/tmp/JetBrainsMono.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
    unzip -oq /tmp/JetBrainsMono.zip -d ~/.local/share/fonts
    fc-cache -f
fi

# 6. GNOME CONFIGURATIONS (Gsettings & Libadwaita Fix)
if ask_task "apply GNOME UI settings (Dark, Nautilus, Battery, Fonts & Visual Fix)"; then
    echo -e "${BLUE}Applying gsettings...${NC}"
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
    #gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-blue-dark'
    gsettings set org.gnome.desktop.interface icon-theme 'Yaru-blue-dark'
    #gsettings set org.gnome.desktop.interface cursor-theme 'Breeze_cursors'
    gsettings set org.gnome.desktop.interface monospace-font-name 'JetBrainsMono Nerd Font 10'
    gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'
    gsettings set org.gnome.desktop.interface show-battery-percentage true
    gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
    gsettings set org.gnome.nautilus.preferences default-sort-order 'type'
    
    #mkdir -p ~/.config/gtk-4.0
    #ln -sf /usr/share/themes/Yaru-dark-blue/gtk-4.0/gtk.css ~/.config/gtk-4.0/gtk.css
    #ln -sf /usr/share/themes/Yaru-dark-blue/gtk-4.0/gtk-dark.css ~/.config/gtk-4.0/gtk-dark.css
    #ln -sf /usr/share/themes/Yaru-dark-blue/gtk-4.0/assets ~/.config/gtk-4.0/assets
fi

# 7. GNOME EXTENSIONS
#if ask_task "install extensions (Dash to Dock, User Themes, Blur my Shell, Vitals, etc.)"; then
#    sudo dnf install -y jq unzip
#    EXT_IDS=(615 1401 307 3843 19 1460 3193)
#    mkdir -p ~/.local/share/gnome-shell/extensions
#    for ID in "${EXT_IDS[@]}"; do
#        UUID=$(curl -s "https://extensions.gnome.org/extension-query/?pk=$ID" | jq -r '.uuid')
#        VERSION_TAG=$(curl -s "https://extensions.gnome.org/extension-query/?pk=$ID" | jq -r '.shell_version_map | to_entries | last | .value.pk')
#        DOWNLOAD_URL="https://extensions.gnome.org/download-extension/$UUID.shell-extension.zip?version_tag=$VERSION_TAG"
#        mkdir -p ~/.local/share/gnome-shell/extensions/$UUID
#        curl -sL "$DOWNLOAD_URL" -o /tmp/ext.zip
#        unzip -oq /tmp/ext.zip -d ~/.local/share/gnome-shell/extensions/$UUID
#    done
#fi

# 8. VS Code
if ask_task "install Visual Studio Code"; then
    sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
    echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo
    sudo dnf install code -y
fi

# 9. RUST Tools
if ask_task "install Rust, Cargo, and tools (bat, exa, ytop)"; then
    sudo dnf install rust cargo rust-doc -y
    cargo install bat exa ytop
fi

# 11. FISH SHELL
if ask_task "install and configure FISH (Default shell and Plugins)"; then
    sudo dnf install -y fish
    sudo usermod -s /usr/bin/fish $(whoami)
    chsh -s $(which fish)
    fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
    fish -c "fisher install jhillyerd/plugin-git gazorby/fish-exa IlanCosman/tide@v5"
fi

# 12. Final Tools & Cleanup
if ask_task "install Tweaks, Extension Manager and Cleanup"; then
    sudo dnf install gnome-tweaks gnome-extensions-app -y
    sudo dnf autoremove -y
    sudo dnf clean all
fi

# 13. Hostname Setup
if ask_task "set a new Hostname for this machine"; then
    echo -ne "${GREEN}Enter the desired hostname: ${NC}"
    read -r new_hostname
    if [[ -n "$new_hostname" ]]; then
        sudo hostnamectl set-hostname "$new_hostname"
        echo -e "${BLUE}Hostname changed to $new_hostname${NC}"
    fi
fi

echo -e "\n${BLUE}Script finished! Please REBOOT your system.${NC}"
