#!/bin/bash

# Get package manager type
if [ "$(which apt)" != "" ]; then
  package_manager="apt"
elif [ "$(which dnf)" != "" ]; then
  package_manager="dnf"
else
  echo "Error: Package Manager Unsupported"
  echo "Package Manager must be one of the following:"
  echo "apt dnf"
  exit
fi

source ./bin/common/functions.sh

function cleanup() {
  unset loading

  unset fromStartupScript

  unset package_manager
}
trap cleanup EXIT

fromStartupScript="$1"

if [ "$package_manager" = "apt" ]; then
  if [ -z "$fromStartupScript" ] ; then
    loading=$(startLoading "Fixing Common Apt Issues")
    (
      sudo killall apt apt-get &>/dev/null
      sudo dpkg --configure -a &>/dev/null
      sudo apt -y --fix-broken install &>/dev/null

      endLoading "$loading"
    ) &
    runLoading "$loading"
  fi

  loading=$(startLoading "Fixing potential dual monitor issues with nvidia")
  (
    # fix potential duel monitor issues
    sudo apt -y install xserver-xorg-video-nouveau &>/dev/null
    sudo apt -y purge nvidia* &>/dev/null
    sudo apt -y install xserver-xorg-video-nouveau &>/dev/null

    # fix lockscreen monitor
    sudo cp ~/.config/monitors.xml ~gdm/.config/ &>/dev/null

    endLoading "$loading"
  ) &
  runLoading "$loading"
fi

loading=$(startLoading "Installing linux file systems")
(
  if [ "$package_manager" = "apt" ]; then
    sudo apt -y install btrfs-progs &>/dev/null # btrfs
    sudo apt -y install lvm2 &>/dev/null # lvm2
    sudo apt -y install xfsprogs &>/dev/null # xfs
    sudo apt -y install udftools &>/dev/null # udf
  else
    sudo dnf -y install btrfs-progs &>/dev/null # btrfs
    sudo dnf -y install lvm2 &>/dev/null # lvm2
    sudo dnf -y install xfsprogs &>/dev/null # xfs
    sudo dnf -y install udftools &>/dev/null # udf
  fi

  endLoading "$loading"
) &
runLoading "$loading"

loading=$(startLoading "Installing hplip-gui for printer")
(
  if [ "$package_manager" = "apt" ]; then
    sudo apt -y install hplip-gui &>/dev/null
  else
    sudo dnf -y install hplip hplip-gui &>/dev/null
  fi

  xdg-open https://askubuntu.com/a/977851 &>/dev/null 2>&1 & disown

  endLoading "$loading"
) &
runLoading "$loading"

loading=$(startLoading "Reducing system freezing chance with high memory usage")
(
  sudo cp ./bin/apps/set-ram-limit.sh /etc/init.d/set-ram-limit
  sudo chmod +x /etc/init.d/set-ram-limit

  sudo update-rc.d set-ram-limit defaults
  sudo service set-ram-limit start

  bash ./bin/apps/set-ram-limit.sh

  endLoading "$loading"
) &
runLoading "$loading"

loading=$(startLoading "Fixing other common issues")
(
  if ! [ -f "$HOME/.hidden" ]; then
    sudo touch "$HOME/.hidden" &>/dev/null
  fi

  if ! [ -f "/etc/skel/.hidden" ]; then
    sudo touch "/etc/skel/.hidden" &>/dev/null
  fi

  # hide core folder
  if ! grep -q "core" "$HOME/.hidden" ; then
    echo snap | sudo tee -a "$HOME/.hidden" &>/dev/null
  fi

  if ! sudo grep -q "core" "/etc/skel/.hidden" ; then
    echo snap | sudo tee -a "/etc/skel/.hidden" &>/dev/null
  fi

  # hide snap folder
  if ! grep -q "snap" "$HOME/.hidden" ; then
    echo snap | sudo tee -a "$HOME/.hidden"
  fi

  if ! sudo grep -q "snap" "/etc/skel/.hidden" ; then
    echo snap | sudo tee -a "/etc/skel/.hidden" &>/dev/null
  fi

  # hide Steam folder
  if ! grep -q "Steam" "$HOME/.hidden" ; then
    echo snap | sudo tee -a "$HOME/.hidden"
  fi

  if ! sudo grep -q "Steam" "/etc/skel/.hidden" ; then
    echo snap | sudo tee -a "/etc/skel/.hidden" &>/dev/null
  fi

  endLoading "$loading"
) &
runLoading "$loading"
