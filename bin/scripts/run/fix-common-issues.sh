#!/bin/bash

source ./bin/scripts/functions/common.sh

function cleanup() {
  unset loading
  unset fixDualMonitor
  unset ranInSetup
}
trap cleanup EXIT

fixDualMonitor="$1"
ranInSetup="$2"


if ! [ "$ranInSetup" = true ] ; then
  loading=$(startLoading "Fixing Common Apt Issues")
  (
    sudo killall apt apt-get &>/dev/null
    sudo dpkg --configure -a &>/dev/null
    sudo apt -y --fix-broken install &>/dev/null

    endLoading "$loading"
  ) &
  runLoading "$loading"
fi


loading=$(startLoading "Fixing potential dual monitor issues")
(
  # fix potential duel monitor issues
  if [ "$fixDualMonitor" = true ] ; then
    sudo apt -y install xserver-xorg-video-nouveau &>/dev/null
    sudo apt -y purge nvidia* &>/dev/null
    sudo apt -y install xserver-xorg-video-nouveau &>/dev/null
  fi

  # fix lockscreen monitor
  sudo cp ~/.config/monitors.xml ~gdm/.config/ &>/dev/null

  endLoading "$loading"
) &
runLoading "$loading"


loading=$(startLoading "Installing linux file systems")
(
  sudo apt -y install btrfs-progs &>/dev/null # btrft
  sudo apt -y install lvm2 &>/dev/null # lvm2
  sudo apt -y install xfsprogs &>/dev/null # xfs
  sudo apt -y install udftools &>/dev/null # udf

  endLoading "$loading"
) &
runLoading "$loading"


loading=$(startLoading "Fixing other issues")
(
  # hide snap folder
  if ! grep -q snap ~/.hidden ; then
    echo snap >> ~/.hidden
  fi

  # hide snap folder for new users
  if ! sudo grep -q snap /etc/skel/.hidden ; then
    echo snap | sudo tee -a /etc/skel/.hidden &>/dev/null
  fi

  # hide Steam folder
  if ! grep -q Steam ~/.hidden ; then
    echo Steam >> ~/.hidden
  fi

  # hide Steam folder for new users
  if ! sudo grep -q Steam /etc/skel/.hidden ; then
    echo Steam | sudo tee -a /etc/skel/.hidden &>/dev/null
  fi

  endLoading "$loading"
) &
runLoading "$loading"
