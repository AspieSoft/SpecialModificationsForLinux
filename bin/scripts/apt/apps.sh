#!/bin/bash

source ./bin/common/functions.sh

function cleanup() {
  unset loading

  unset installNemo
  unset installWine
  unset installIce
  unset installKeyboardCursor
  unset installRecommended
}
trap cleanup EXIT

installNemo="$1"
installWine="$2"
installIce="$3"
installKeyboardCursor="$4"
installRecommended="$5"


# add repositories
loading=$(startLoading "Adding Repositorys")
(
  sudo apt-add-repository -y multiverse &>/dev/null
  sudo apt-add-repository -y universe &>/dev/null
  sudo apt-add-repository -y ppa:obsproject/obs-studio &>/dev/null
  sudo apt-add-repository -y ppa:cybermax-dexter/sdl2-backport &>/dev/null
  sudo apt-add-repository -y ppa:pinta-maintainers/pinta-stable &>/dev/null
  endLoading "$loading"
) &
runLoading "$loading"


# update
runUpdate


# install neofetch
loading=$(startLoading "Installing Neofetch")
(
  if [ $(hasPackage "neofetch") = "false" ] ; then
    sudo apt -y install neofetch &>/dev/null
  fi

  endLoading "$loading"
) &
runLoading "$loading"


# install snap
if [ "$installNemo" = true ] ; then
  loading=$(startLoading "Installing Snap")
  (
    if [ $(hasPackage "snapd") = "false" ] ; then
      sudo apt -y install snapd &>/dev/null
    fi

    endLoading "$loading"
  ) &
  runLoading "$loading"
fi


# install nemo
if [ "$installNemo" = true ] ; then
  loading=$(startLoading "Finding Nemo")
  (
    if [ $(hasPackage "nemo") = "false" ] ; then
      sudo apt -y install nemo &>/dev/null
    fi

    xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search &>/dev/null
    # gsettings set org.gnome.desktop.background show-desktop-icons false
    # gsettings set org.nemo.desktop show-desktop-icons true

    # force nemo over default
    #note: may make Nautilus inaccessible (https://askubuntu.com/a/260249)
    # sudo mv /usr/bin/nautilus /usr/bin/nautilus.back && sudo ln -s /usr/bin/nemo /usr/bin/nautilus &>/dev/null
    # sudo mv /usr/bin/thunar /usr/bin/thunar.back && sudo ln -s /usr/bin/nemo /usr/bin/thunar &>/dev/null

    endLoading "$loading"
  ) &
  runLoading "$loading"
fi


# install wine
if [ "$installWine" = true ] ; then
  loading=$(startLoading "Making Linux Drunk With WINE")
  (
    sudo apt -y --install-recommends install wine-stable &>/dev/null

    #todo: get terminal name of zorinos windows app support
    #sudo apt -y install windows-app-support &>/dev/null

    endLoading "$loading"
  ) &
  runLoading "$loading"
fi


# install ice
if [ "$installIce" = true ] ; then
  loading=$(startLoading "Installing ICE ICE Baby")
  (
  sudo dpkg -i ./bin/apps/ice_5.2.7_all.deb &>/dev/null

  endLoading "$loading"
  ) &
  runLoading "$loading"
fi


# guake terminal
if [ $(hasPackage "guake") = "false" ] ; then
  loading=$(startLoading "Installing Guake Terminal")
  (
    sudo apt -y install guake &>/dev/null
    endLoading "$loading"
  ) &
  runLoading "$loading"
fi

# dconf-editor
if [ $(hasPackage "dconf-editor") = "false" ] ; then
  loading=$(startLoading "Installing dconf Editor")
  (
    sudo apt -y install dconf-editor &>/dev/null
    endLoading "$loading"
  ) &
  runLoading "$loading"
fi


# gnome tools
if echo $XDG_CURRENT_DESKTOP | grep GNOME &>/dev/null ; then
  # gnome-tweak-tool
  if [ $(hasPackage "gnome-tweak-tool") = "false" ] ; then
    loading=$(startLoading "Installing Gnome Tweak Tool")
    (
      sudo apt -y install gnome-tweak-tool &>/dev/null
      endLoading "$loading"
    ) &
    runLoading "$loading"
  fi

  # gnome-shell-extension-manager
  if [ $(hasPackage "gnome-shell-extension-manager") = "false" ] ; then
    loading=$(startLoading "Installing Gnome Extension Manager")
    (
      # sudo apt -y install gnome-shell-extension-manager &>/dev/null
      sudo flatpak install -y flathub com.mattjakeman.ExtensionManager &>/dev/null
      endLoading "$loading"
    ) &
    runLoading "$loading"
  fi
fi


if [ $(hasPackage "gparted") = "false" ] ; then
  loading=$(startLoading "Installing Gparted")
  (
    sudo apt -y install gparted &>/dev/null
    endLoading "$loading"
  ) &
  runLoading "$loading"
fi

if [ $(hasPackage "chromium-browser") = "false" ] ; then
  loading=$(startLoading "Installing Chromium")
  (
    sudo apt -y install chromium-browser &>/dev/null
    endLoading "$loading"
  ) &
  runLoading "$loading"
fi

if [ "$installKeyboardCursor" = true ] ; then
  loading=$(startLoading "Setting Up Keyboard Cursor")
  (
    sudo apt -y install xinput xdotool &>/dev/null

    sudo mkdir -p /etc/aspiesoft-keyboard-cursor
    sudo cp -R -f ./bin/apps/aspiesoft-keyboard-cursor/* /etc/aspiesoft-keyboard-cursor
    sudo rm -f /etc/aspiesoft-keyboard-cursor/aspiesoft-keyboard-cursor.desktop

    sudo cp -f ./bin/apps/aspiesoft-keyboard-cursor/aspiesoft-keyboard-cursor.desktop /home/shaynejr/.config/autostart

    bash /etc/aspiesoft-keyboard-cursor/start.sh &

    endLoading "$loading"
  ) &
  runLoading "$loading"
fi


if ! [ "$installRecommended" = true ] ; then
  exit
fi

# install recommended apps

if [ $(hasPackage "vlc") = "false" ] ; then
  loading=$(startLoading "Installing VLC")
  (
    sudo apt -y install vlc &>/dev/null
    endLoading "$loading"
  ) &
  runLoading "$loading"
fi


if [ $(hasPackage "obs-studio") = "false" ] ; then
  loading=$(startLoading "Installing OBS Studio")
  (
    sudo apt -y install ffmpeg &>/dev/null
    sudo apt -y install obs-studio &>/dev/null

    sudo mkdir -p ~/.config/obs-studio/plugins/advanced-scene-switcher &>/dev/null
    sudo cp -R -f ./bin/apps/advanced-scene-switcher/* ~/.config/obs-studio/plugins/advanced-scene-switcher &>/dev/null

    # for new users
    sudo mkdir -p /etc/skel/.config/obs-studio/plugins/advanced-scene-switcher &>/dev/null
    sudo cp -R -f ./bin/apps/advanced-scene-switcher/* /etc/skel/.config/obs-studio/plugins/advanced-scene-switcher &>/dev/null

    endLoading "$loading"
  ) &
  runLoading "$loading"
fi


if [ $(hasPackage "atom") = "false" ] ; then
  loading=$(startLoading "Installing Atom Text Editor")
  (
    sudo snap install --classic atom &>/dev/null

    sudo mkdir -p $HOME/atom &>/dev/null
    sudo cp -R -f ./bin/apps/atom/* $HOME/.atom &>/dev/null

    # for new users
    sudo mkdir -p /etc/skel/.atom &>/dev/null
    sudo cp -R -f ./bin/apps/atom/* /etc/skel/.atom &>/dev/null

    endLoading "$loading"
  ) &
  runLoading "$loading"
fi


if [ $(hasPackage "code") = "false" ] ; then
  loading=$(startLoading "Installing VSCode")
  (
    sudo snap install --classic code &>/dev/null

    code --install-extension Shan.code-settings-sync &>/dev/null

    # for new users
    sudo mkdir -p /etc/skel/.vscode/extensions &>/dev/null
    sudo cp -R -f ~/.vscode/extensions/* /etc/skel/.vscode/extensions &>/dev/null

    endLoading "$loading"
  ) &
  runLoading "$loading"
fi


if [ $(hasPackage "eclipse") = "false" ] ; then
  loading=$(startLoading "Installing Eclipse")
  (
    sudo snap install --classic eclipse &>/dev/null

    endLoading "$loading"
  ) &
  runLoading "$loading"
fi


if [ $(hasPackage "blender") = "false" ] ; then
  loading=$(startLoading "Installing Blender")
  (
    sudo snap install --classic blender &>/dev/null
    endLoading "$loading"
  ) &
  runLoading "$loading"
fi


if [ $(hasPackage "pinta") = "false" ] ; then
  loading=$(startLoading "Installing Pinta")
  (
    sudo apt -y install pinta &>/dev/null
    endLoading "$loading"
  ) &
  runLoading "$loading"
fi


if [ $(hasPackage "steam") = "false" ] ; then
  loading=$(startLoading "Installing Steam")
  (
    sudo apt -y install steam &>/dev/null

    if ! [ ! -z $(grep "Steam" "$HOME/.hidden") ] ; then
      echo 'Steam' | sudo tee -a $HOME/.hidden &>/dev/null
    fi

    # for new users
    if ! [ ! -z $(grep "Steam" "/etc/skel/.hidden") ] ; then
      echo 'Steam' | sudo tee -a /etc/skel/.hidden &>/dev/null
    fi

    endLoading "$loading"
  ) &
  runLoading "$loading"
fi


if [ $(hasPackage "video-downloader") = "false" ] ; then
  loading=$(startLoading "Installing Video Downloader")
  (
    sudo snap install video-downloader &>/dev/null
    endLoading "$loading"
  ) &
  runLoading "$loading"
fi