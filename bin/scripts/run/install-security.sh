#!/bin/bash

source ./bin/scripts/functions/common.sh

function cleanup() {
  unset loading
}
trap cleanup EXIT


loading=$(startLoading "Adding Security Scanners")
(

  #sudo apt -y install clamtk clamav &>/dev/null

  if [ $(hasPackage "clamav") = "false" ] ; then
    sudo apt -y install clamav &>/dev/null
  fi

  if [ $(hasPackage "clamtk") = "false" ] ; then
    sudo apt -y install clamtk &>/dev/null
  fi

  cp -R -f ./bin/apps/clamtk/* ~/.clamtk
  #sudo sed -r -i "s/USERNAME/$USER/g" ~/.clamtk/cron

  sudo freshclam &>/dev/null
  sudo mkdir -p /VirusScan/quarantine &>/dev/null
  sudo chmod 664 /VirusScan/quarantine &>/dev/null

  if [ $(hasPackage "bleachbit") = "false" ] ; then
    sudo apt -y install bleachbit &>/dev/null
  fi

  if [ $(hasPackage "inotify-tools") = "false" ] ; then
    sudo apt -y install inotify-tools &>/dev/null
  fi

  endLoading "$loading"
) &
runLoading "$loading"


loading=$(startLoading "Setting Up Download Scanner")
(
  sudo mkdir -p /etc/aspiesoft-clamav-scanner
  sudo cp -R -f ./bin/apps/aspiesoft-clamav-scanner/* /etc/aspiesoft-clamav-scanner
  sudo rm -f /etc/aspiesoft-clamav-scanner/aspiesoft-clamav-scanner.desktop

  #sudo echo -e '#''!/bin/sh\nbash /etc/aspiesoft-clamav-scanner/start.sh\n' | sudo tee /etc/init.d/aspiesoft-clamav-scanner
  #sudo chmod +x /etc/init.d/aspiesoft-clamav-scanner
  #sudo ln -s /etc/init.d/aspiesoft-clamav-scanner /etc/rc.d/aspiesoft-clamav-scanner

  sudo cp -f ./bin/apps/aspiesoft-clamav-scanner/aspiesoft-clamav-scanner.desktop /home/shaynejr/.config/autostart

  #sudo update-rc.d aspiesoft-clamav-scanner defaults
  #sudo /etc/init.d/aspiesoft-clamav-scanner start

  bash /etc/aspiesoft-clamav-scanner/start.sh &

  endLoading "$loading"
) &
runLoading "$loading"
