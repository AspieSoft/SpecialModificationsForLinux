#!/bin/bash

source ./bin/scripts/functions/common.sh

function cleanup() {
  unset loading
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

  if [ $(hasPackage "preload") = "false" ] ; then
    sudo apt -y install preload &>/dev/null
  fi

  sudo add-apt-repository -y ppa:linrunner/tlp &>/dev/null
  sudo apt -y update &>/dev/null

  if [ $(hasPackage "tlp") = "false" ] ; then
    sudo apt -y install tlp &>/dev/null
  fi
  if [ $(hasPackage "tlp-rdw") = "false" ] ; then
    sudo apt -y install tlp-rdw &>/dev/null
  fi

  sudo systemctl enable tlp &>/dev/null
  sudo tlp start &>/dev/null

  sudo snap install auto-cpufreq &>/dev/null
  sudo auto-cpufreq --install &>/dev/null

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

  if [ "$disableUbuntuErrorReporting" = true ] ; then
    sudo systemctl disable whoopsie.service &>/dev/null # ubuntu error reporting
  fi

  # todo: see if "cups.service" can be delayed
  # todo: see if "snapd.service" can be delayed (takes 2 seconds at boot)
  # todo: see if "plymouth-quit-wait.service" can be delayed or disabled (takes 7 seconds at boot)
  # todo: see if "dev-sdc3.device" can be delayed or disabled (takes 12 seconds at boot)

  endLoading "$loading"
) &
runLoading "$loading"


loading=$(startLoading "Improving multitasking preformance")
(
  sudo cp ./bin/apps/set-ram-limit.sh /etc/init.d/set-ram-limit
  sudo chmod +x /etc/init.d/set-ram-limit

  sudo update-rc.d set-ram-limit defaults
  sudo service set-ram-limit start

  bash ./bin/apps/set-ram-limit.sh

  endLoading "$loading"
) &
runLoading "$loading"


#loading=$(startLoading "Changing Swappiness")
#(
#  echo -e '\nvm.swappiness=10\n' | sudo tee -a /etc/sysctl.conf &>/dev/null
#) &
#runLoading "$loading"
