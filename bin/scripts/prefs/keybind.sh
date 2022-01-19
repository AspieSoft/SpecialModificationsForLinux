#!/bin/bash

gsettings set org.gnome.desktop.wm.keybindings maximize []
gsettings set org.gnome.desktop.wm.keybindings unmaximize []
gsettings set org.gnome.desktop.wm.keybindings move-to-monitor-up []
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-down "['<Shift><Super>Down']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-up "['<Shift><Super>Up']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-down "['<Super>Down']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-up "['<Super>Up']"
