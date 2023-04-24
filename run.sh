#!/bin/bash

echo "Special Modifacations by AspieSoft"
echo "$(cat ./bin/falcon.txt)"
echo

function cleanup() {
  unset input
  unset -f main

  # reset login timeout
  sudo sed -r -i 's/^Defaults([\t ]+)(.*)env_reset(.*), (timestamp_timeout=1801,?\s*)+$/Defaults\1\2env_reset\3/m' /etc/sudoers &>/dev/null

  # enable sleep
  # sudo systemctl --runtime unmask sleep.target suspend.target hibernate.target hybrid-sleep.target &>/dev/null

  # enable auto updates
  # sudo sed -r -i 's/^APT::Periodic::Update-Package-Lists "([0-9]+)";$/APT::Periodic::Update-Package-Lists "1";/m' /etc/apt/apt.conf.d/20auto-upgrades &>/dev/null
  # sudo sed -r -i 's/^APT::Periodic::Unattended-Upgrade "([0-9]+)";$/APT::Periodic::Unattended-Upgrade "1";/m' /etc/apt/apt.conf.d/20auto-upgrades &>/dev/null
}
trap cleanup EXIT

# To log into sudo with password prompt
sudo echo

# extend login timeout
# sudo sed -r -i 's/^Defaults([\t ]+)(.*)env_reset(.*)$/Defaults\1\2env_reset\3, timestamp_timeout=1801/m' /etc/sudoers &>/dev/null
#
# # disable sleep
# sudo systemctl --runtime mask sleep.target suspend.target hibernate.target hybrid-sleep.target &>/dev/null

# disable auto updates
# sudo sed -r -i 's/^APT::Periodic::Update-Package-Lists "([0-9]+)";$/APT::Periodic::Update-Package-Lists "0";/m' /etc/apt/apt.conf.d/20auto-upgrades &>/dev/null
# sudo sed -r -i 's/^APT::Periodic::Unattended-Upgrade "([0-9]+)";$/APT::Periodic::Unattended-Upgrade "0";/m' /etc/apt/apt.conf.d/20auto-upgrades &>/dev/null


function main() {
  echo
  echo "[0] Exit"
  echo "[1] Setup Distro"
  echo "[2] Fix Common Issues"
  echo "[3] Run Virus Scan"
  echo "[4] Update Linux Kernel"
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
    bash ./bin/scripts/fix.sh
  elif [ "$input" -eq "3" ] ; then
    bash ./bin/scripts/virus-scan.sh
  elif [ "$input" -eq "4" ] ; then
    bash ./bin/scripts/update-linux-kernel.sh
  else
    exit
  fi

  main
}

main
