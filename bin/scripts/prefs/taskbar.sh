#!/bin/bash

intellihide="$1"

gsettings set org.gnome.shell.extensions.zorin-taskbar isolate-monitors true
gsettings set org.gnome.shell.extensions.zorin-taskbar isolate-workspaces true
gsettings set org.gnome.shell.extensions.zorin-taskbar multi-monitors true

gsettings set org.gnome.shell.extensions.zorin-taskbar panel-element-positions {"0":[{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}],"1":[{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":false,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":false,"position":"stackedBR"}]}

gsettings set org.gnome.shell.extensions.zorin-taskbar panel-element-positions-monitors-sync false
gsettings set org.gnome.shell.extensions.zorin-taskbar show-showdesktop-icon false


if [ "$intellihide" = "true" ] ; then
  gsettings set org.gnome.shell.extensions.zorin-taskbar intellihide true
  gsettings set org.gnome.shell.extensions.zorin-taskbar intellihide-behaviour 'ALL_WINDOWS'
  gsettings set org.gnome.shell.extensions.zorin-taskbar intellihide-floating-rounded-theme false
  gsettings set org.gnome.shell.extensions.zorin-taskbar intellihide-only-secondary true
  gsettings set org.gnome.shell.extensions.zorin-taskbar intellihide-show-in-fullscreen true
fi
