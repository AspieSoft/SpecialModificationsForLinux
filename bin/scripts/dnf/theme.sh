#!/bin/bash

# set basic theme
git clone https://github.com/vinceliuice/Fluent-gtk-theme.git &>/dev/null
sudo bash Fluent-gtk-theme/install.sh --theme all --dest /usr/share/themes --size standard --icon zorin --tweaks round noborder &>/dev/null
rm -rf Fluent-gtk-theme &>/dev/null

sudo cp -R -f ./bin/themes/icons/* /usr/share/icons &>/dev/null
sudo cp -R -f ./bin/themes/sounds/* /usr/share/sounds &>/dev/null
sudo cp -R -f ./bin/themes/backgrounds/* /usr/share/backgrounds &>/dev/null

gsettings set org.gnome.desktop.interface gtk-theme "Fluent-round-Dark" &>/dev/null
gsettings set org.gnome.desktop.interface icon-theme "ZorinBlue-Dark" &>/dev/null
gsettings set org.gnome.desktop.sound theme-name "zorin" &>/dev/null


#todo: add gnome extentions
sudo pip3 install --upgrade gnome-extentions-cli &>/dev/null
 
gext -F install arcmenu@arcmenu.com
gext -F install dash-to-panel@jderose9.github.com
gext -F install vertical-workspaces@G-dH.github.com
gext -F install user-theme@gnome-shell-extensions.gcampax.github.com
gext -F install burn-my-windows@schneegans.github.com
gext -F install gnome-ui-tune@itstime.tech
gext -F install gtk4-ding@smedius.gitlab.com
gext -F install drive-menu@gnome-shell-extensions.gcampax.github.com
gext -F install mediacontrols@cliffniff.github.com
gext -F install date-menu-formatter@marcinjakubowski.github.com
gext -F install batterytime@typeof.pw
gext -F install ControlBlurEffectOnLockScreen@pratap.fastmail.fm
gext -F install clipboard-indicator@tudmotu.com
gext -F install screenshot-window-sizer@gnome-shell-extensions.gcampax.github.com
gext -F install compiz-alike-magic-lamp-effect@hermes83.github.com
gext -F install printers@linux-man.org
gext -F install gestureimprovements@gestures
gext -F install just-perfection-desktop@just-perfection

gext -F install another-window-session-manager@gmail.com

#todo: find alternative for fedora
# gext -F install remove-dropdown-arrows@mpdeimos.com

gext -F install mousefollowsfocus@matthes.biz
gext disable mousefollowsfocus@matthes.biz

gext -F install Vitals@CoreCoding.com
gext disable Vitals@CoreCoding.com

gext -F install allowlockedremotedesktop@kamens.us
gext disable allowlockedremotedesktop@kamens.us

gext -F install wsmatrix@martin.zurowietz.de
gext disable wsmatrix@martin.zurowietz.de


# fix keyboard shortcuts
dconf reset /org/gnome/desktop/wm/keybindings/switch-to-workspace-up
dconf reset /org/gnome/desktop/wm/keybindings/switch-to-workspace-down
dconf reset /org/gnome/desktop/wm/keybindings/switch-to-workspace-left
dconf reset /org/gnome/desktop/wm/keybindings/switch-to-workspace-right

dconf reset /org/gnome/desktop/wm/keybindings/move-to-workspace-up
dconf reset /org/gnome/desktop/wm/keybindings/move-to-workspace-down
dconf reset /org/gnome/desktop/wm/keybindings/move-to-workspace-left
dconf reset /org/gnome/desktop/wm/keybindings/move-to-workspace-right

dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-up "['<Super>Up']"
dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-down "['<Super>Down']"
dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-left "['<Super>Left']"
dconf write /org/gnome/desktop/wm/keybindings/switch-to-workspace-right "['<Super>Right']"

dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-up "['<Shift><Super>Up']"
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-down "['<Shift><Super>Down']"
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-left "['<Shift><Super>Left']"
dconf write /org/gnome/desktop/wm/keybindings/move-to-workspace-right "['<Shift><Super>Right']"


# config extension settings

#* arcmenu
dconf write /org/gnome/shell/extentions/arcmenu/arcmenu-extra-categories-links "[(0, false), (1, true), (2, false), (3, false), (4, true)]"
dconf write /org/gnome/shell/extentions/arcmenu/custom-menu-button-icon-size "24.0"
dconf write /org/gnome/shell/extentions/arcmenu/directory-shortcuts-list "[['Computer', 'drive-harddisk-symbolic', 'ArcMenu_Computer'], ['Home', 'user-home-symbolic', 'ArcMenu_Home'], ['Documents', '. GThemedIcon folder-documents-symbolic folder-symbolic folder-documents folder', 'ArcMenu_Documents'], ['Downloads', '. GThemedIcon folder-download-symbolic folder-symbolic folder-download folder', 'ArcMenu_Downloads'], ['Music', '. GThemedIcon folder-music-symbolic folder-symbolic folder-music folder', 'ArcMenu_Music'], ['Pictures', '. GThemedIcon folder-pictures-symbolic folder-symbolic folder-pictures folder', 'ArcMenu_Pictures'], ['Videos', '. GThemedIcon folder-videos-symbolic folder-symbolic folder-videos folder', 'ArcMenu_Videos']]"
dconf write /org/gnome/shell/extentions/arcmenu/extra-categories "[(0, false), (1, false), (3, true), (4, false), (2, true)]"
dconf write /org/gnome/shell/extentions/arcmenu/hide-overview-on-startup "True"

#* dash to panel
dconf write /org/gnome/shell/extentions/dash-to-panel/hide-overview-on-startup "True"
dconf write /org/gnome/shell/extentions/dash-to-panel/intellihide "True"
dconf write /org/gnome/shell/extentions/dash-to-panel/intellihide-behaviour "ALL_WINDOWS"
dconf write /org/gnome/shell/extentions/dash-to-panel/intellihide-hide-from-windows "True"
dconf write /org/gnome/shell/extentions/dash-to-panel/intellihide-only-secondary "True"
dconf write /org/gnome/shell/extentions/dash-to-panel/isolate-monitors "True"
dconf write /org/gnome/shell/extentions/dash-to-panel/isolate-workspaces "True"
dconf write /org/gnome/shell/extentions/dash-to-panel/panel-element-positions '{"0":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}],"1":[{"element":"showAppsButton","visible":false,"position":"stackedTL"},{"element":"activitiesButton","visible":false,"position":"stackedTL"},{"element":"leftBox","visible":true,"position":"stackedTL"},{"element":"taskbar","visible":true,"position":"stackedTL"},{"element":"centerBox","visible":true,"position":"stackedBR"},{"element":"rightBox","visible":true,"position":"stackedBR"},{"element":"dateMenu","visible":true,"position":"stackedBR"},{"element":"systemMenu","visible":true,"position":"stackedBR"},{"element":"desktopButton","visible":true,"position":"stackedBR"}]}'
dconf write /org/gnome/shell/extentions/dash-to-panel/dot-style-unfocused "DOTS"

#* vertical workspaces
dconf write /org/gnome/shell/extentions/vertical-workspaces/fix-ubuntu-dock "True"
dconf write /org/gnome/shell/extentions/vertical-workspaces/hot-corner-action "0"
dconf write /org/gnome/shell/extentions/vertical-workspaces/overview-bg-blur-sigma "10"
dconf write /org/gnome/shell/extentions/vertical-workspaces/search-fuzzy "True"
dconf write /org/gnome/shell/extentions/vertical-workspaces/blur-transitions "True"
# dconf write /org/gnome/shell/extentions/vertical-workspaces/ws-sw-popup-mode "1"

#* desktop icons
dconf write /org/gnome/shell/extentions/gtk4-ding/show-drop-place "False"
dconf write /org/gnome/shell/extentions/gtk4-ding/show-home "False"
dconf write /org/gnome/shell/extentions/gtk4-ding/show-second-monitor "True"
dconf write /org/gnome/shell/extentions/gtk4-ding/use-nemo "True"

#* burn my windows
sudo cp -f ./bin/themes/burn-my-windows.conf "$HOME/.config/burn-my-windows/profiles/"
dconf write /org/gnome/shell/extentions/burn-my-windows/active-profile "$HOME/.config/burn-my-windows/profiles/burn-my-windows.conf"

#* date formatter
dconf write /org/gnome/shell/extentions/date-menu-formatter/apply-all-panels "True"
dconf write /org/gnome/shell/extentions/date-menu-formatter/pattern "EEE, MMM d  h:mm aaa"

#* printers
dconf write /org/gnome/shell/extentions/printers/show-icon "When printing"

#* just perfection
dconf write /org/gnome/shell/extentions/just-perfection/hot-corner "False"
dconf write /org/gnome/shell/extentions/just-perfection/startup-status "0"
dconf write /org/gnome/shell/extentions/just-perfection/workspace-wrap-around "True"
dconf write /org/gnome/shell/extentions/just-perfection/window-demands-attention-focus "False"


#* disable other extentions
gext disable background-logo@fedorahosted.org &>/dev/null


# restart gnome shell (note: this will log out the user and close all programs)
killall -3 gnome-shell
