#!/bin/bash

# Get package manager type
if [ "$(which apt)" != "" ] &>/dev/null; then
  package_manager="apt"
elif [ "$(which dnf)" != "" ] &>/dev/null; then
  package_manager="dnf"
else
  echo "Error: Package Manager Unsupported"
  echo "Package Manager must be one of the following:"
  echo "apt dnf"
  exit
fi

function cleanup() {
  unset package_manager
}
trap cleanup EXIT

if [ "$package_manager" = "apt" ]; then
  wget https://raw.githubusercontent.com/pimlie/ubuntu-mainline-kernel.sh/master/ubuntu-mainline-kernel.sh
  sudo chmod a+x ubuntu-mainline-kernel.sh
  sudo install ubuntu-mainline-kernel.sh /usr/local/bin
  sudo ubuntu-mainline-kernel.sh -i
elif
  #curl -s https://repos.fedorapeople.org/repos/thl/kernel-vanilla.repo | sudo tee /etc/yum.repos.d/kernel-vanilla.repo
  #sudo dnf --enablerepo=kernel-vanilla-stable update

  sudo dnf -y install kernel --best
fi

#todo: sign kernel for secure boot

sudo reboot
