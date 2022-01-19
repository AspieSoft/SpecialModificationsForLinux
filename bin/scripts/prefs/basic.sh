#!/bin/bash

idleDelay="$1"
terminalName="$2"

gsettings set org.nemo.icon-view default-zoom-level 'small'
gsettings set org.nemo.preferences date-format 'informal'
gsettings set org.nemo.preferences show-compact-view-icon-toolbar false
gsettings set org.nemo.preferences show-computer-icon-toolbar true
gsettings set org.nemo.preferences show-home-icon-toolbar true
gsettings set org.nemo.preferences show-location-entry true
gsettings set org.nemo.preferences show-reload-icon-toolbar true
gsettings set org.nemo.preferences thumbnail-limit 104857600
gsettings set org.nemo.list-view default-column-order "['name', 'size', 'date_modified', 'permissions']"
gsettings set org.nemo.list-view default-visible-columns "['name', 'size', 'date_modified', 'permissions']"

gsettings set org.gnome.desktop.interface clock-format '12h'
gsettings set org.gnome.desktop.interface clock-show-weekday true
gsettings set org.gnome.desktop.interface gtk-im-module 'gtk-im-context-simple'

gsettings set org.gtk.Settings.FileChooser clock-format '12h'


if [ "$idleDelay" = "true" ] ; then
  gsettings set org.gnome.desktop.session idle-delay 900
fi


if [ "$terminalName" = "true" ] ; then
  sudo sed -r -i "s/^([\s\t ]*)PS1=([\"'])(.*?)\\\\u@\\\\h(.*?)\2$/\1PS1=\2\3\\\\u@zorinos\4\2/m" $HOME/.bashrc &>/dev/null
fi
