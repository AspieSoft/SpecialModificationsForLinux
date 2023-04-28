#!/bin/bash

source ./bin/common/functions.sh

function cleanup() {
  unset loading

  unset grubTimeout
  unset grubBadRam
  unset disableUbuntuErrorReporting
}
trap cleanup EXIT

grubTimeout="$1"
grubBadRam="$2"
disableUbuntuErrorReporting="$3"


# modify grub menu timeout
loading=$(startLoading "Editing Grub Menu")
(
  sudo cp -n /etc/default/grub /etc/default/grub-backup

  sudo sed -r -i 's/^GRUB_TIMEOUT_STYLE=(.*)$/GRUB_TIMEOUT_STYLE=menu/m' /etc/default/grub
  sudo sed -r -i "s/^GRUB_TIMEOUT=(.*)$/GRUB_TIMEOUT=$grubTimeout/m" /etc/default/grub

  if [ "$grubBadRam" = true ] ; then
    sudo sed -r -i "s/^\#GRUB_BADRAM=/GRUB_BADRAM=/m" /etc/default/grub
  fi

  sudo update-grub &>/dev/null

  endLoading "$loading"
) &
runLoading "$loading"


# preformance upgrades
loading=$(startLoading "Upgrading preformance")
(

  #todo: fix preload install not working
  if [ $(hasPackage "preload") = "false" ] ; then
    sudo dnf -y install preload &>/dev/null
  fi

  systemctl start preload &>/dev/null
  systemctl enable preload &>/dev/null

  if [ $(hasPackage "tlp-rdw") = "false" ] ; then
    sudo dnf -y install tlp-rdw &>/dev/null
  fi

  systemctl start tlp &>/dev/null
  systemctl enable tlp &>/dev/null
  sudo tlp start &>/dev/null

  if [ $(hasPackage "thermald") = "false" ] ; then
    sudo dnf -y install thermald &>/dev/null
  fi

  sudo systemctl start thermald &>/dev/null
  sudo systemctl enable thermald &>/dev/null

  endLoading "$loading"
) &
runLoading "$loading"


# boot time improvements
loading=$(startLoading "Disabling time wasting startup programs")
(
  sudo systemctl disable postfix.service &>/dev/null # for email server
  sudo systemctl disable NetworkManager-wait-online.service &>/dev/null # wastes time connectiong to wifi
  sudo systemctl disable networkd-dispatcher.service &>/dev/null # depends on the time waster above
  sudo systemctl disable systemd-networkd.service &>/dev/null # depends on the time waster above
  sudo systemctl disable accounts-daemon.service &>/dev/null # is a potential securite risk
  sudo systemctl disable debug-shell.service &>/dev/null # opens a giant security hole
  sudo systemctl disable pppd-dns.service &>/dev/null # dial-up internet (its way outdated)

  endLoading "$loading"
) &
runLoading "$loading"


#loading=$(startLoading "Changing Swappiness")
#(
#  echo -e '\nvm.swappiness=10\n' | sudo tee -a /etc/sysctl.conf &>/dev/null
#) &
#runLoading "$loading"
