# Things to do after installing Fedora Workstation

## DNF flags
```
echo 'fastestmirror=true' | sudo tee -a /etc/dnf/dnf.conf
echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf
echo 'deltarpm=true' | sudo tee -a /etc/dnf/dnf.conf
cat /etc/dnf/dnf.conf
```

## Update
```
sudo dnf upgrade --refresh --assumeyes
sudo dnf check
sudo dnf autoremove --assumeyes
```

## Firmware
```
sudo fwupdmgr get-devices
sudo fwupdmgr refresh --force
sudo fwupdmgr get-updates
sudo fwupdmgr update
```

## Set Hostname
```
sudo hostnamectl set-hostname new-name
```

## Flatpak
```
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub -y com.discordapp.Discord
```

## Rust Tools
```
sudo dnf install -y cargo
cargo install bat exa ytop
```

## Apps
```
sudo dnf install -y gnome-tweaks gnome-extensions-app
sudo dnf install -y neovim breeze-cursor-theme
sudo dnf install -y conky lm_sensors gnome-shell-extension-appindicator
sudo dnf install -y yaru-icon-theme yaru-gtk3-theme breeze-cursor-theme numix-gtk-theme
sudo dnf install -y flameshot
```

## Fish
```
sudo dnf install -y fish
sudo usermod -s /usr/bin/fish $(whoami)

chsh -s $(which fish)
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
fisher install jhillyerd/plugin-git
fisher install gazorby/fish-exa
fisher install IlanCosman/tide@v5
```

## Gnome Extensions
```
https://extensions.gnome.org/extension/615/appindicator-support/
https://extensions.gnome.org/extension/1401/bluetooth-quick-connect/
https://extensions.gnome.org/extension/307/dash-to-dock/
https://extensions.gnome.org/extension/4158/gnome-40-ui-improvments/
https://extensions.gnome.org/extension/3843/just-perfection/
https://extensions.gnome.org/extension/355/status-area-horizontal-spacing/
https://extensions.gnome.org/extension/19/user-themes/
https://extensions.gnome.org/extension/1460/vitals/
https://extensions.gnome.org/extension/6807/system-monitor/
```

## VSCode
```
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\nautorefresh=1\ntype=rpm-md\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" | sudo tee /etc/yum.repos.d/vscode.repo > /dev/null
dnf check-update
sudo dnf install -y code
```

## 1Passwords
```
sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
sudo dnf install -y 1password
```

## Google Chrome
```
sudo dnf install -y fedora-workstation-repositories
sudo dnf config-manager setopt google-chrome.enabled=1
sudo dnf install -y google-chrome-stable
```

## JetBrains ToolBox
```
sudo ./install-jetbrains.sh 
/opt/jetbrains-toolbox/jetbrains-toolbox
```








## RPM Fusion
```
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

## ZSH
```
sudo dnf install -y zsh
sudo usermod -s /usr/bin/zsh $(whoami)
```

## insync
```
sudo rpm --import https://d2t3ff60b2tol4.cloudfront.net/repomd.xml.key
sudo sh -c 'echo -e "[InSync]\nname=Insync\nbaseurl=http://yum.insync.io/fedora/\$releasever/\ngpgcheck=1\ngpgkey=https://d2t3ff60b2tol4.cloudfront.net/repomd.xml.key\nenabled=1\nmetadata_expire=120m" > /etc/yum.repos.d/insync.repo'
sudo dnf check-update
sudo dnf install -y insync
```

## Docker
```
sudo curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
sudo sh /tmp/get-docker.sh
sudo usermod -aG docker $(logname)
sudo systemctl enable docker
sudo systemctl start docker
```
