#!/bin/bash

keybind="$1"

gsettings set guake.general gtk-prefer-dark-theme true
gsettings set guake.general start-at-login true
gsettings set guake.general tab-ontop true
gsettings set guake.general window-height 32
gsettings set guake.general window-valignment 1
gsettings set guake.style.background transparency 85


if [ "$keybind" = "true" ] ; then
  gsettings set guake.keybindings.global show-hide 'Menu'
fi

# xmodmap -e "keycode 105=Menu"
