#!/bin/bash

# set basic theme
git clone https://github.com/vinceliuice/Fluent-gtk-theme.git
sudo bash Fluent-gtk-theme/install.sh --theme all --dest /usr/share/themes --size standard --icon zorin --tweaks round noborder
rm -rf Fluent-gtk-theme

sudo cp -R -f ./bin/apps/GnomeThemes/icons/* /usr/share/icons
sudo cp -R -f ./bin/apps/GnomeThemes/sounds/* /usr/share/sounds

gsettings set org.gnome.desktop.interface gtk-theme "Fluent-round-Dark"
gsettings set org.gnome.desktop.interface icon-theme "ZorinBlue-Dark"
gsettings set org.gnome.desktop.sound theme-name "zorin"

#todo: add gnome extentions
