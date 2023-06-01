#!/bin/bash

source ./bin/common/functions.sh

function cleanup() {
  unset loading
}
trap cleanup EXIT


# install clamav, bleachbit, etc.
loading=$(startLoading "Installing Security Software")
(
  if [ $(hasPackage "clamav") = "false" ] ; then
    sudo apt -y install clamav &>/dev/null
  fi

  if [ $(hasPackage "clamav-daemon") = "false" ] ; then
    sudo apt -y install clamav-daemon &>/dev/null
  fi

  if [ $(hasPackage "clamtk") = "false" ] ; then
    sudo apt -y install clamtk &>/dev/null
  fi

  #cp -R -f ./bin/apps/clamtk/* ~/.clamtk
  #sudo sed -r -i "s/USERNAME/$USER/g" ~/.clamtk/cron

  sudo freshclam &>/dev/null
  sudo mkdir -p /VirusScan/quarantine &>/dev/null
  sudo chmod 664 /VirusScan/quarantine &>/dev/null

  # fix clamav permissions
  if grep -R "^ScanOnAccess " "/etc/clamav/clamd.conf"; then
    sudo sed -r -i 's/^ScanOnAccess (.*)$/ScanOnAccess true/m' /etc/clamav/clamd.conf
  else
    echo 'ScanOnAccess true' | sudo tee -a /etc/clamav/clamd.conf &>/dev/null
  fi

  if grep -R "^OnAccessMountPath " "/etc/clamav/clamd.conf"; then
    sudo sed -r -i 's#^OnAccessMountPath (.*)$#OnAccessMountPath /#m' /etc/clamav/clamd.conf
  else
    echo 'OnAccessMountPath /' | sudo tee -a /etc/clamav/clamd.conf &>/dev/null
  fi

  if grep -R "^OnAccessPrevention " "/etc/clamav/clamd.conf"; then
    sudo sed -r -i 's/^OnAccessPrevention (.*)$/OnAccessPrevention false/m' /etc/clamav/clamd.conf
  else
    echo 'OnAccessPrevention false' | sudo tee -a /etc/clamav/clamd.conf &>/dev/null
  fi

  if grep -R "^OnAccessExtraScanning " "/etc/clamav/clamd.conf"; then
    sudo sed -r -i 's/^OnAccessExtraScanning (.*)$/OnAccessExtraScanning true/m' /etc/clamav/clamd.conf
  else
    echo 'OnAccessExtraScanning true' | sudo tee -a /etc/clamav/clamd.conf &>/dev/null
  fi

  if grep -R "^OnAccessExcludeUID " "/etc/clamav/clamd.conf"; then
    sudo sed -r -i 's/^OnAccessExcludeUID (.*)$/OnAccessExcludeUID 0/m' /etc/clamav/clamd.conf
  else
    echo 'OnAccessExcludeUID 0' | sudo tee -a /etc/clamav/clamd.conf &>/dev/null
  fi

  if grep -R "^User " "/etc/clamav/clamd.conf"; then
    sudo sed -r -i 's/^User (.*)$/User root/m' /etc/clamav/clamd.conf
  else
    echo 'User root' | sudo tee -a /etc/clamav/clamd.conf &>/dev/null
  fi

  sudo apt -y install apparmor-utils &>/dev/null
  sudo aa-complain clamd &>/dev/null


  if [ $(hasPackage "bleachbit") = "false" ] ; then
    sudo apt -y install bleachbit &>/dev/null
  fi

  endLoading "$loading"
) &
runLoading "$loading"


# install aspiesoft download scanner
loading=$(startLoading "Setting Up Download Scanner")
(
  if [ $(hasPackage "inotify-tools") = "false" ] ; then
    sudo apt -y install inotify-tools &>/dev/null
  fi

  sudo mkdir -p /etc/aspiesoft-clamav-scanner
  sudo cp -R -f ./bin/apps/aspiesoft-clamav-scanner/* /etc/aspiesoft-clamav-scanner
  sudo rm -f /etc/aspiesoft-clamav-scanner/aspiesoft-clamav-scanner.desktop

  #sudo echo -e '#''!/bin/sh\nbash /etc/aspiesoft-clamav-scanner/start.sh\n' | sudo tee /etc/init.d/aspiesoft-clamav-scanner
  #sudo chmod +x /etc/init.d/aspiesoft-clamav-scanner
  #sudo ln -s /etc/init.d/aspiesoft-clamav-scanner /etc/rc.d/aspiesoft-clamav-scanner

  sudo cp -f ./bin/apps/aspiesoft-clamav-scanner/aspiesoft-clamav-scanner.desktop $HOME/.config/autostart

  #sudo update-rc.d aspiesoft-clamav-scanner defaults
  #sudo /etc/init.d/aspiesoft-clamav-scanner start

  bash /etc/aspiesoft-clamav-scanner/start.sh &

  endLoading "$loading"
) &
runLoading "$loading"
