# Things to do after installing Fedora Workstation

## Install updates and reboot
```properties
sudo dnf upgrade --refresh --assumeyes
sudo dnf check
sudo dnf autoremove --assumeyes
sudo fwupdmgr get-devices
sudo fwupdmgr refresh --force
sudo fwupdmgr get-updates
sudo fwupdmgr update
sudo reboot now
```

## DNF flags
```properties
echo 'fastestmirror=true' | sudo tee -a /etc/dnf/dnf.conf
echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf
echo 'deltarpm=true' | sudo tee -a /etc/dnf/dnf.conf
cat /etc/dnf/dnf.conf
```

## Set hostname
```properties
sudo hostnamectl set-hostname new-name
```

## RPM Fusion
```properties
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

## packages
```properties
sudo dnf install -y neovim conky lm_sensors breeze-cursor-theme flameshot
sudo dnf install -y gnome-tweaks gnome-shell-extension-appindicator gnome-extensions-app
sudo dnf install -y yaru-icon-theme yaru-gtk3-theme breeze-cursor-theme numix-gtk-theme
```

## Ferramentas Rust
```properties
sudo dnf install -y cargo
cargo install bat exa ytop
```

## ZSH
```properties
sudo dnf install -y zsh
sudo usermod -s /usr/bin/zsh $(whoami)
```

## vscode
```properties
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[VSCode]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf check-update
sudo dnf install -y code
```

## insync
```properties
sudo rpm --import https://d2t3ff60b2tol4.cloudfront.net/repomd.xml.key
sudo sh -c 'echo -e "[InSync]\nname=Insync\nbaseurl=http://yum.insync.io/fedora/\$releasever/\ngpgcheck=1\ngpgkey=https://d2t3ff60b2tol4.cloudfront.net/repomd.xml.key\nenabled=1\nmetadata_expire=120m" > /etc/yum.repos.d/insync.repo'
sudo dnf check-update
sudo dnf install -y insync
```

## google chrome browser
```properties
sudo dnf install -y fedora-workstation-repositories
sudo dnf config-manager --set-enabled google-chrome --assumeyes
sudo dnf install google-chrome-stable --assumeyes
```

## brave browser
```properties
sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/ --assumeyes
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo dnf install brave-browser --assumeyes
```

## youtube-dl
```properties
sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
sudo chmod a+rx /usr/local/bin/youtube-dl
```

## Docker
```properties
sudo curl -fsSL https://get.docker.com -o /tmp/get-docker.sh
sudo sh /tmp/get-docker.sh
sudo usermod -aG docker $(logname)
sudo systemctl enable docker
sudo systemctl start docker
```
