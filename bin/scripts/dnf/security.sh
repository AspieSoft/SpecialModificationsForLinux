#!/bin/bash

source ./bin/common/functions.sh

function cleanup() {
  unset loading
}
trap cleanup EXIT


# install clamav, bleachbit, etc.
loading=$(startLoading "Installing Security Software")
(

  #todo: lookup different clamav install for fedora https://www.linuxcapable.com/install-clamav-on-fedora-linux/
  # may be able to reduce cpu usage

  sudo dnf -y install clamav clamd clamav-update &>/dev/null

  sudo systemctl stop clamav-freshclam &>/dev/null
  sudo freshclam &>/dev/null
  sudo systemctl enable clamav-freshclam --now &>/dev/null

  if [ $(hasPackage "clamtk") = "false" ] ; then
    sudo dnf -y install clamtk &>/dev/null
  fi

  #cp -R -f ./bin/apps/clamtk/* ~/.clamtk
  #sudo sed -r -i "s/USERNAME/$USER/g" ~/.clamtk/cron

  sudo dnf install cronie

  sudo freshclam &>/dev/null
  sudo mkdir -p /VirusScan/quarantine &>/dev/null
  sudo chmod 664 /VirusScan/quarantine &>/dev/null

  # fix clamav permissions
  if grep -R "^ScanOnAccess " "/etc/clamd.d/scan.conf"; then
    sudo sed -r -i 's/^ScanOnAccess (.*)$/ScanOnAccess yes/m' /etc/clamd.d/scan.conf
  else
    echo 'ScanOnAccess yes' | sudo tee -a /etc/clamd.d/scan.conf &>/dev/null
  fi

  if grep -R "^OnAccessMountPath " "/etc/clamd.d/scan.conf"; then
    sudo sed -r -i 's#^OnAccessMountPath (.*)$#OnAccessMountPath /#m' /etc/clamd.d/scan.conf
  else
    echo 'OnAccessMountPath /' | sudo tee -a /etc/clamd.d/scan.conf &>/dev/null
  fi

  if grep -R "^OnAccessPrevention " "/etc/clamd.d/scan.conf"; then
    sudo sed -r -i 's/^OnAccessPrevention (.*)$/OnAccessPrevention no/m' /etc/clamd.d/scan.conf
  else
    echo 'OnAccessPrevention no' | sudo tee -a /etc/clamd.d/scan.conf &>/dev/null
  fi

  if grep -R "^OnAccessExtraScanning " "/etc/clamd.d/scan.conf"; then
    sudo sed -r -i 's/^OnAccessExtraScanning (.*)$/OnAccessExtraScanning yes/m' /etc/clamd.d/scan.conf
  else
    echo 'OnAccessExtraScanning yes' | sudo tee -a /etc/clamd.d/scan.conf &>/dev/null
  fi

  if grep -R "^OnAccessExcludeUID " "/etc/clamd.d/scan.conf"; then
    sudo sed -r -i 's/^OnAccessExcludeUID (.*)$/OnAccessExcludeUID 0/m' /etc/clamd.d/scan.conf
  else
    echo 'OnAccessExcludeUID 0' | sudo tee -a /etc/clamd.d/scan.conf &>/dev/null
  fi

  if grep -R "^User " "/etc/clamd.d/scan.conf"; then
    sudo sed -r -i 's/^User (.*)$/User root/m' /etc/clamd.d/scan.conf
  else
    echo 'User root' | sudo tee -a /etc/clamd.d/scan.conf &>/dev/null
  fi

  if [ $(hasPackage "bleachbit") = "false" ] ; then
    sudo dnf -y install bleachbit &>/dev/null
  fi

  endLoading "$loading"
) &
runLoading "$loading"


# install aspiesoft download scanner
loading=$(startLoading "Setting Up Download Scanner")
(
  if [ $(hasPackage "inotify-tools") = "false" ] ; then
    sudo dnf -y install inotify-tools &>/dev/null
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
