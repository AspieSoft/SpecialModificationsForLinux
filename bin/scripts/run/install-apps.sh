#!/bin/bash

source ./bin/scripts/functions/common.sh

function cleanup() {
  unset loading

  unset installNemo
  unset installWine
  unset installIce
  unset installRecommended
  unset installExtras
}
trap cleanup EXIT

installNemo="$1"
installWine="$2"
installIce="$3"
installRecommended="$4"
# installExtras="$5"


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


# install nemo
if [ "$installNemo" = true ] ; then
  loading=$(startLoading "Finding Nemo")
  (
    if [ $(hasPackage "nemo") = "false" ] ; then
      sudo apt -y install nemo &>/dev/null
    fi

    xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search
    gsettings set org.gnome.desktop.background show-desktop-icons false
    gsettings set org.nemo.desktop show-desktop-icons true

    endLoading "$loading"
  ) &
  runLoading "$loading"
fi

# install wine
if [ "$installWine" = true ] ; then
  bash ./bin/scripts/run/install-wine.sh
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

# install extras
# if [ "$installExtras" = true ] ; then
#   loading=$(startLoading "Installing Ubuntu Extras")
#   (
#     #todo: prevent need to confirm license
#     sudo apt -y install ubuntu-restricted-extras &>/dev/null

#     endLoading "$loading"
#   ) &
#   runLoading "$loading"
# fi


# install other apps

if [ $(hasPackage "guake") = "false" ] ; then
  loading=$(startLoading "Installing Guake Terminal")
  (
    sudo apt -y install guake &>/dev/null
    endLoading "$loading"
  ) &
  runLoading "$loading"
fi


if [ $(hasPackage "dconf-editor") = "false" ] ; then
  loading=$(startLoading "Installing dconf Editor")
  (
    sudo apt -y install dconf-editor &>/dev/null
    endLoading "$loading"
  ) &
  runLoading "$loading"
fi


if [ $(hasPackage "gnome-tweak-tool") = "false" ] ; then
  loading=$(startLoading "Installing Gnome Tweak Tool")
  (
    sudo apt -y install gnome-tweak-tool &>/dev/null
    endLoading "$loading"
  ) &
  runLoading "$loading"
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


#todo: fix dpkg-query package not found (probobly caused by snap or --classic)
if [ $(hasPackage "atom") = "false" ] ; then
  loading=$(startLoading "Installing Atom Text Editor")
  (
    sudo snap install --classic atom &>/dev/null

    sudo mkdir -p ./bin/apps/atom &>/dev/null
    sudo cp -R -f ./bin/apps/atom/* ~/.atom &>/dev/null

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
