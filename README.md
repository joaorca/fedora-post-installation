# Things to do after installing Fedora Workstation

## Install updates and reboot
```bash
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
```bash
echo 'fastestmirror=1' | sudo tee -a /etc/dnf/dnf.conf
echo 'max_parallel_downloads=10' | sudo tee -a /etc/dnf/dnf.conf
echo 'deltarpm=true' | sudo tee -a /etc/dnf/dnf.conf
cat /etc/dnf/dnf.conf
```

## Set hostname
```bash
sudo hostnamectl set-hostname new-name
```

## RPM Fusion
```bash
sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
sudo dnf install -y https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
```

## packages
```bash
sudo dnf install -y vim conky flameshot lm_sensors gnome-tweaks gnome-shell-extension-appindicator
sudo dnf install -y yaru-icon-theme yaru-gtk3-theme numix-gtk-theme breeze-cursor-theme
```

## zsh
```bash
sudo dnf install -y zsh
sudo usermod -s /usr/bin/zsh $(whoami)
```

## vscode
```bash
sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
sudo dnf check-update
sudo dnf install -y code
```

## google chrome
```bash
sudo dnf install -y fedora-workstation-repositories
sudo dnf config-manager --set-enabled google-chrome --assumeyes
sudo dnf install google-chrome-stable --assumeyes
```

## youtube-dl
```bash
sudo curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl 
sudo chmod a+rx /usr/local/bin/youtube-dl
```

## Docker
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $(whoami)
sudo systemctl enable docker
```

## Insync

## Rambox

## Insomnia

## GitKraken

