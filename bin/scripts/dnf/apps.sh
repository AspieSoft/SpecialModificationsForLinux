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
  # install rpm fusion
  sudo dnf -y install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm &>/dev/null

  # optional (non-free)
  sudo dnf -y install https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm &>/dev/null

  sudo fedora-third-party enable &>/dev/null
  sudo fedora-third-party refresh &>/dev/null

  sudo dnf -y groupupdate core


  # activate flathub
  sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo &>/dev/null


  # install codecs
  sudo dnf install -y --skip-broken @multimedia &>/dev/null
  sudo dnf -y groupupdate multimedia --setop="install_weak_deps=False" --exclude=PackageKit-gstreamer-plugin --skip-broken &>/dev/null
  sudo dnf -y groupupdate sound-and-video &>/dev/null


  sudo dnf -y install fedora-workstation-repositories &>/dev/null
  sudo dnf -y config-manager --set-enabled google-chrome &>/dev/null


  # add microsoft keys for vscode
  sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
  if ! test -f "/etc/yum.repos.d/vscode.repo" ; then
    echo '[code]' | sudo tee -a "/etc/yum.repos.d/vscode.repo" &>/dev/null
    echo 'name=Visual Studio Code' | sudo tee -a "/etc/yum.repos.d/vscode.repo" &>/dev/null
    echo 'baseurl=https://packages.microsoft.com/yumrepos/vscode' | sudo tee -a "/etc/yum.repos.d/vscode.repo" &>/dev/null
    echo 'enabled=1' | sudo tee -a "/etc/yum.repos.d/vscode.repo" &>/dev/null
    echo 'gpgcheck=1' | sudo tee -a "/etc/yum.repos.d/vscode.repo" &>/dev/null
    echo 'gpgkey=https://packages.microsoft.com/keys/microsoft.asc' | sudo tee -a "/etc/yum.repos.d/vscode.repo" &>/dev/null
  fi

  # add repo for atom text editor
  sudo rpm --import https://packagecloud.io/AtomEditor/atom/gpgkey
  if ! test -f "/etc/yum.repos.d/atom.repo" ; then
    echo '[Atom]' | sudo tee -a "/etc/yum.repos.d/atom.repo" &>/dev/null
    echo 'name=atom' | sudo tee -a "/etc/yum.repos.d/atom.repo" &>/dev/null
    echo 'baseurl=https://packagecloud.io/AtomEditor/atom/el/7/$basearch' | sudo tee -a "/etc/yum.repos.d/atom.repo" &>/dev/null
    echo 'enabled=1' | sudo tee -a "/etc/yum.repos.d/atom.repo" &>/dev/null
    echo 'gpgcheck=0' | sudo tee -a "/etc/yum.repos.d/atom.repo" &>/dev/null
    echo 'repo_gpgcheck=1' | sudo tee -a "/etc/yum.repos.d/atom.repo" &>/dev/null
    echo 'gpgkey=https://packagecloud.io/AtomEditor/atom/gpgkey' | sudo tee -a "/etc/yum.repos.d/atom.repo" &>/dev/null
  fi

  sudo dnf check-update


  endLoading "$loading"
) &
runLoading "$loading"


# update
runUpdate


# install neofetch
loading=$(startLoading "Installing Neofetch")
(
  if [ $(hasPackage "neofetch") = "false" ] ; then
    sudo dnf -y install neofetch &>/dev/null
  fi

  endLoading "$loading"
) &
runLoading "$loading"


# install flatseal
loading=$(startLoading "Installing Flatseal")
(
  sudo flatpak install -y flathub com.github.tchx84.Flatseal &>/dev/null

  endLoading "$loading"
) &
runLoading "$loading"


# install snap
# loading=$(startLoading "Installing Snap")
# (
#   if [ $(hasPackage "snapd") = "false" ] ; then
#     sudo dnf -y install snapd &>/dev/null
#   fi

#   sudo ln -s /var/lib/snapd/snap /snap

#   sudo snap refresh &>/dev/null

#   endLoading "$loading"
# ) &
# runLoading "$loading"


# install nemo
if [ "$installNemo" = true ] ; then
  loading=$(startLoading "Finding Nemo")
  (
    if [ $(hasPackage "nemo") = "false" ] ; then
      sudo dnf -y install nemo &>/dev/null
    fi

    xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search &>/dev/null
    # gsettings set org.gnome.desktop.background show-desktop-icons false
    # gsettings set org.nemo.desktop show-desktop-icons true

    # force nemo over default
    #note: may make Nautilus inaccessible (https://askubuntu.com/a/260249)
    # sudo mv /usr/bin/nautilus /usr/bin/nautilus.back && sudo ln -s /usr/bin/nemo /usr/bin/nautilus &>/dev/null
    # sudo mv /usr/bin/thunar /usr/bin/thunar.back && sudo ln -s /usr/bin/nemo /usr/bin/thunar &>/dev/null

    sudo sed -r -i "s/^OnlyShowIn=/#OnlyShowIn=/m" /usr/share/applications/nemo.desktop

    if [ $(hasPackage "nemo-fileroller") = "false" ] ; then
      sudo dnf -y install nemo-fileroller &>/dev/null
    fi

    endLoading "$loading"
  ) &
  runLoading "$loading"
fi


# install wine
if [ "$installWine" = true ] ; then
  loading=$(startLoading "Making Linux Drunk With WINE")
  (
    sudo dnf config-manager --add-repo https://dl.winehq.org/wine-builds/fedora/38/winehq.repo &>/dev/null
    sudo dnf -y install winehq-stable &>/dev/null

    sudo dnf -y install alsa-plugins-pulseaudio.i686 glibc-devel.i686 glibc-devel libgcc.i686 libX11-devel.i686 freetype-devel.i686 libXcursor-devel.i686 libXi-devel.i686 libXext-devel.i686 libXxf86vm-devel.i686 libXrandr-devel.i686 libXinerama-devel.i686 mesa-libGLU-devel.i686 mesa-libOSMesa-devel.i686 libXrender-devel.i686 libpcap-devel.i686 ncurses-devel.i686 libzip-devel.i686 lcms2-devel.i686 zlib-devel.i686 libv4l-devel.i686 libgphoto2-devel.i686  cups-devel.i686 libxml2-devel.i686 openldap-devel.i686 libxslt-devel.i686 gnutls-devel.i686 libpng-devel.i686 flac-libs.i686 json-c.i686 libICE.i686 libSM.i686 libXtst.i686 libasyncns.i686 libedit.i686 liberation-narrow-fonts.noarch libieee1284.i686 libogg.i686 libsndfile.i686 libuuid.i686 libva.i686 libvorbis.i686 libwayland-client.i686 libwayland-server.i686 llvm-libs.i686 mesa-dri-drivers.i686 mesa-filesystem.i686 mesa-libEGL.i686 mesa-libgbm.i686 nss-mdns.i686 ocl-icd.i686 pulseaudio-libs.i686  sane-backends-libs.i686 tcp_wrappers-libs.i686 unixODBC.i686 samba-common-tools.x86_64 samba-libs.x86_64 samba-winbind.x86_64 samba-winbind-clients.x86_64 samba-winbind-modules.x86_64 mesa-libGL-devel.i686 fontconfig-devel.i686 libXcomposite-devel.i686 libtiff-devel.i686 openal-soft-devel.i686 mesa-libOpenCL-devel.i686 opencl-utils-devel.i686 alsa-lib-devel.i686 gsm-devel.i686 libjpeg-turbo-devel.i686 pulseaudio-libs-devel.i686 pulseaudio-libs-devel gtk3-devel.i686 libattr-devel.i686 libva-devel.i686 libexif-devel.i686 libexif.i686 glib2-devel.i686 mpg123-devel.i686 mpg123-devel.x86_64 libcom_err-devel.i686 libcom_err-devel.x86_64 libFAudio-devel.i686 libFAudio-devel.x86_64 &>/dev/null

    sudo dnf -y groupinstall "C Development Tools and Libraries" &>/dev/null
    sudo dnf -y groupinstall "Development Tools" &>/dev/null

    #todo: fix packages not found for rpm-fusion dependend installs
    # sudo dnf -y install gstreamer-plugins-base-devel gstreamer-devel.i686 gstreamer.i686 gstreamer-plugins-base.i686 gstreamer-devel gstreamer1.i686 gstreamer1-devel gstreamer1-plugins-base-devel.i686 gstreamer-plugins-base.x86_64 gstreamer.x86_64 gstreamer1-devel.i686 gstreamer1-plugins-base-devel gstreamer-plugins-base-devel.i686 gstreamer-ffmpeg.i686 gstreamer1-plugins-bad-free-devel.i686 gstreamer1-plugins-bad-free-extras.i686 gstreamer1-plugins-good-extras.i686 gstreamer1-libav.i686 gstreamer1-plugins-bad-freeworld.i686 &>/dev/null

    endLoading "$loading"
  ) &
  runLoading "$loading"
fi


# guake terminal
# if [ $(hasPackage "guake") = "false" ] ; then
#   loading=$(startLoading "Installing Guake Terminal")
#   (
#     #todo: find alternative to guake (dropdown terminal)
#     # sudo apt -y install guake &>/dev/null
#     endLoading "$loading"
#   ) &
#   runLoading "$loading"
# fi


# dconf-editor
if [ $(hasPackage "dconf-editor") = "false" ] ; then
  loading=$(startLoading "Installing dconf Editor")
  (
    sudo dnf -y install dconf-editor &>/dev/null
    endLoading "$loading"
  ) &
  runLoading "$loading"
fi


# gnome tools
if echo $XDG_CURRENT_DESKTOP | grep GNOME &>/dev/null ; then
  # gnome-tweak-tool
  if [ $(hasPackage "gnome-tweaks") = "false" ] ; then
    loading=$(startLoading "Installing Gnome Tweak Tool")
    (
      sudo dnf -y install gnome-tweaks &>/dev/null

      endLoading "$loading"
    ) &
    runLoading "$loading"
  fi

  # gnome-shell-extension-manager
  if [ $(hasPackage "gnome-shell-extension-manager") = "false" ] ; then
    loading=$(startLoading "Installing Gnome Extension Manager")
    (
      sudo flatpak install -y flathub org.gnome.Extensions &>/dev/null
      sudo flatpak install -y flathub com.mattjakeman.ExtensionManager &>/dev/null

      endLoading "$loading"
    ) &
    runLoading "$loading"
  fi
fi


if [ $(hasPackage "gparted") = "false" ] ; then
  loading=$(startLoading "Installing Gparted")
  (
    sudo dnf -y install gparted &>/dev/null
    endLoading "$loading"
  ) &
  runLoading "$loading"
fi

if [ $(hasPackage "chromium") = "false" ] ; then
  loading=$(startLoading "Installing Chromium")
  (
    sudo dnf -y install chromium &>/dev/null
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
    sudo dnf -y install vlc &>/dev/null
    endLoading "$loading"
  ) &
  runLoading "$loading"
fi


if [ $(hasPackage "obs-studio") = "false" ] ; then
  loading=$(startLoading "Installing OBS Studio")
  (
    sudo dnf -y --skip-broken install ffmpeg &>/dev/null
    # sudo dnf -y --allowerasing install obs-studio &>/dev/null
    sudo flatpak install -y flathub com.obsproject.Studio &>/dev/null

    # plugins
    sudo mkdir -p "$HOME/.var/app/com.obsproject.Studio/config/obs-studio/plugins/advanced-scene-switcher" &>/dev/null
    sudo cp -R -f ./bin/apps/advanced-scene-switcher/* "$HOME/.var/app/com.obsproject.Studio/config/obs-studio/plugins/advanced-scene-switcher" &>/dev/null

    # # for new users
    sudo mkdir -p /etc/skel/.var/app/com.obsproject.Studio/config/obs-studio/plugins/advanced-scene-switcher &>/dev/null
    sudo cp -R -f ./bin/apps/advanced-scene-switcher/* /etc/skel/.var/app/com.obsproject.Studio/config/obs-studio/plugins/advanced-scene-switcher &>/dev/null

    endLoading "$loading"
  ) &
  runLoading "$loading"
fi


if [ $(hasPackage "shotcut") = "false" ] ; then
  loading=$(startLoading "Installing Shotcut")
  (
    sudo flatpak install -y flathub org.shotcut.Shotcut &>/dev/null

    endLoading "$loading"
  ) &
  runLoading "$loading"
fi


if [ $(hasPackage "atom") = "false" ] ; then
  loading=$(startLoading "Installing Atom Text Editor")
  (
    sudo dnf -y install atom &>/dev/null

    sudo mkdir -p $HOME/.atom &>/dev/null
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
    sudo dnf -y install code &>/dev/null

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
    # sudo snap install --classic eclipse &>/dev/null
    sudo flatpak install -y flathub org.eclipse.Java &>/dev/null

    endLoading "$loading"
  ) &
  runLoading "$loading"
fi


if [ $(hasPackage "blender") = "false" ] ; then
  loading=$(startLoading "Installing Blender")
  (
    # sudo snap install --classic blender &>/dev/null
    sudo flatpak install -y flathub org.blender.Blender &>/dev/null

    endLoading "$loading"
  ) &
  runLoading "$loading"
fi


if [ $(hasPackage "gimp") = "false" ] ; then
  loading=$(startLoading "Installing GNU Image Manipulation")
  (
    # sudo snap install gimp &>/dev/null
    sudo flatpak install -y flathub org.gimp.GIMP &>/dev/null

    endLoading "$loading"
  ) &
  runLoading "$loading"
fi

if [ $(hasPackage "pinta") = "false" ] ; then
  loading=$(startLoading "Installing Pinta")
  (
    sudo dnf -y install pinta &>/dev/null
    endLoading "$loading"
  ) &
  runLoading "$loading"
fi


if [ $(hasPackage "steam") = "false" ] ; then
  loading=$(startLoading "Installing Steam")
  (flatpak
    # sudo dnf -y --skip-broken install steam &>/dev/null

    # sudo flatpak install -y flathub com.valvesoftware.Steam &>/dev/null

    sudo dnf -y module disable nodejs &>/dev/null
    sudo dnf -y install steam &>/dev/null
    sudo dnf -y module install -y nodejs:16/development &>/dev/null
    # sudo dnf -y module enable nodejs &>/dev/null

    if ! [ ! -z $(grep "Steam" "$HOME/.hidden") ] ; then
      echo 'Steam' | sudo tee -a "$HOME/.hidden" &>/dev/null
    fi

    # for new users
    if ! [ ! -z $(grep "Steam" "/etc/skel/.hidden") ] ; then
      echo 'Steam' | sudo tee -a "/etc/skel/.hidden" &>/dev/null
    fi

    endLoading "$loading"
  ) &
  runLoading "$loading"
fi


if [ $(hasPackage "video-downloader") = "false" ] ; then
  loading=$(startLoading "Installing Video Downloader")
  (
    # sudo snap install video-downloader &>/dev/null
    sudo flatpak install -y flathub com.github.unrud.VideoDownloader &>/dev/null

    endLoading "$loading"
  ) &
  runLoading "$loading"
fi
