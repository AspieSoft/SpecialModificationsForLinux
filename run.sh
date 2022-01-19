#!/bin/bash

echo "Special Modifacations by AspieSoft"
echo "$(cat ./bin/falcon.txt)"
echo


source ./bin/scripts/more/shortcuts.sh
source ./bin/scripts/fix.sh
source ./bin/scripts/more/upgrade.sh
source ./bin/scripts/more/apps.sh
source ./bin/scripts/more/p-languages.sh
source ./bin/scripts/more/security.sh


function cleanup() {
  unset input
  unset -f main
  unset -f more

  # reset login timeout
  sudo sed -r -i 's/^Defaults([\t ]+)(.*)env_reset(.*), (timestamp_timeout=1801,?\s*)+$/Defaults\1\2env_reset\3/m' /etc/sudoers &>/dev/null

  # enable sleep
  sudo systemctl --runtime unmask sleep.target suspend.target hibernate.target hybrid-sleep.target &>/dev/null

  # enable auto updates
  sudo sed -r -i 's/^APT::Periodic::Update-Package-Lists "([0-9]+)";$/APT::Periodic::Update-Package-Lists "1";/m' /etc/apt/apt.conf.d/20auto-upgrades &>/dev/null
  sudo sed -r -i 's/^APT::Periodic::Unattended-Upgrade "([0-9]+)";$/APT::Periodic::Unattended-Upgrade "1";/m' /etc/apt/apt.conf.d/20auto-upgrades &>/dev/null
}
trap cleanup EXIT


# To log into sudo with password prompt
sudo echo


# extend login timeout
sudo sed -r -i 's/^Defaults([\t ]+)(.*)env_reset(.*)$/Defaults\1\2env_reset\3, timestamp_timeout=1801/m' /etc/sudoers &>/dev/null

# disable sleep
sudo systemctl --runtime mask sleep.target suspend.target hibernate.target hybrid-sleep.target &>/dev/null

# disable auto updates
sudo sed -r -i 's/^APT::Periodic::Update-Package-Lists "([0-9]+)";$/APT::Periodic::Update-Package-Lists "0";/m' /etc/apt/apt.conf.d/20auto-upgrades &>/dev/null
sudo sed -r -i 's/^APT::Periodic::Unattended-Upgrade "([0-9]+)";$/APT::Periodic::Unattended-Upgrade "0";/m' /etc/apt/apt.conf.d/20auto-upgrades &>/dev/null


function main() {

  echo
  echo "[0] Exit"
  echo "[1] Setup Distro"
  echo "[2] Run Virus Scan"
  echo "[3] Setup Recommended Preferences"
  echo "[4] Install WINE"
  echo "[5] More Options..."
  echo
  read -p "What would you like to do? " input

  if [ -z "$input" ] ; then
    exit
  fi

  if [ "$input" -eq "0" ] ; then
    exit
  elif [ "$input" -eq "1" ] ; then
    bash ./bin/scripts/setup.sh
  elif [ "$input" -eq "2" ] ; then
    bash ./bin/scripts/scan.sh
  elif [ "$input" -eq "3" ] ; then
    bash ./bin/scripts/prefs/run.sh
  elif [ "$input" -eq "4" ] ; then
    bash ./bin/scripts/run/install-wine.sh
  elif [ "$input" -eq "5" ] ; then
    more
    exit
  else
    exit
  fi

  main
}

function more() {

  echo
  echo "[0] Back"
  echo "[1] Upgrade Preformance"
  echo "[2] Add Command Shortcuts"
  echo "[3] Fix Common Issues"
  echo "[4] Install Programing Languages"
  echo "[5] Install Apps"
  echo

  read -p "What would you like to do? " input

  if [ -z "$input" ] ; then
    main
    exit
  fi

  if [ "$input" -eq "0" ] ; then
    main
    exit
  elif [ "$input" -eq "1" ] ; then
    upgrade_run_basic
  elif [ "$input" -eq "2" ] ; then
    shortcuts_run_basic
  elif [ "$input" -eq "3" ] ; then
    fix_run_basic
  elif [ "$input" -eq "4" ] ; then
    pLang_run_basic
  elif [ "$input" -eq "5" ] ; then
    apps_run_basic
  else
    main
    exit
  fi

  main
}

main
