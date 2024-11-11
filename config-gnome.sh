#!/usr/bin/env bash

EXTENSION_DIR=${HOME}/.local/share/gnome-shell/extensions

rm -rf ${EXTENSION_DIR}/gTile@vibou
git clone --quiet https://github.com/gTile/gTile.git \
  ${EXTENSION_DIR}/gTile@vibou
gnome-extensions enable gTile@vibou

rm -rf ${EXTENSION_DIR}/status-area-horizontal-spacing@mathematical.coffee.gmail.com
git clone --quiet https://gitlab.com/p91paul/status-area-horizontal-spacing-gnome-shell-extension.git \
   ${EXTENSION_DIR}/status-area-horizontal-spacing@mathematical.coffee.gmail.com
gnome-extensions enable status-area-horizontal-spacing@mathematical.coffee.gmail.com

rm -rf ${EXTENSION_DIR}/sound-output-device-chooser@kgshank.net
git clone --quiet https://github.com/kgshank/gse-sound-output-device-chooser.git \
  ${EXTENSION_DIR}/sound-output-device-chooser
cp --recursive ${EXTENSION_DIR}/sound-output-device-chooser/sound-output-device-chooser@kgshank.net \
  ${EXTENSION_DIR}/sound-output-device-chooser@kgshank.net
rm -rf ${EXTENSION_DIR}/sound-output-device-chooser
gnome-extensions enable sound-output-device-chooser@kgshank.net

#gsettings set org.gnome.desktop.interface gtk-theme 'Yaru-dark'
#gsettings set org.gnome.desktop.interface cursor-theme 'breeze_cursors'

#https://extensions.gnome.org/extension/2890/tray-icons-reloaded/
https://extensions.gnome.org/extension/906/sound-output-device-chooser/
https://extensions.gnome.org/extension/615/appindicator-support/



https://extensions.gnome.org/extension/307/dash-to-dock/
https://extensions.gnome.org/extension/4158/gnome-40-ui-improvments/
https://extensions.gnome.org/extension/355/status-area-horizontal-spacing/
https://extensions.gnome.org/extension/6807/system-monitor/
