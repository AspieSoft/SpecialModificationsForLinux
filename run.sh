#!/bin/bash

cd $(dirname "$0")

echo "Special Modifacations by AspieSoft"
echo "$(cat ./bin/falcon.txt)"
echo

function cleanup() {
  unset input
  unset -f main

  # reset login timeout
  sudo sed -r -i 's/^Defaults([\t ]+)(.*)env_reset(.*), (timestamp_timeout=1801,?\s*)+$/Defaults\1\2env_reset\3/m' /etc/sudoers &>/dev/null
}
trap cleanup EXIT

# To log into sudo with password prompt
sudo echo

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
    bash ./bin/scripts/main/setup.sh
  elif [ "$input" -eq "2" ] ; then
    bash ./bin/scripts/main/fix.sh
  elif [ "$input" -eq "3" ] ; then
    bash ./bin/scripts/main/virus-scan.sh
  elif [ "$input" -eq "4" ] ; then
    bash ./bin/scripts/main/update-linux-kernel.sh
  else
    exit
  fi

  main
}

main
