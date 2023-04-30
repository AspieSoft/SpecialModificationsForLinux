#!/bin/bash

if [ "$(which apt)" != "" ]; then
  package_manager="apt"
elif [ "$(which dnf)" != "" ]; then
  package_manager="dnf"
else
  echo "Error: Package Manager Unsupported"
  echo "Package Manager must be one of the following:"
  echo "apt dnf"
  exit
fi

echo "Special Modifacations by AspieSoft"
echo "Installer"
echo

sudo echo

echo
echo "Installing..."

if [ "$package_manager" = "apt" ]; then
  sudo apt -y install git &>/dev/null
elif [ "$package_manager" = "dnf" ]; then
  sudo dnf -y install git &>/dev/null
fi

git clone -n --depth=1 --filter=tree:0 https://github.com/AspieSoft/SpecialModificationsForLinux.git &>/dev/null
cd SpecialModificationsForLinux

git sparse-checkout set --no-cone "bin/common/" "bin/scripts/main/" "bin/scripts/$package_manager/" "bin/falcon.txt" "bin/printer-fix.png" "readme.md" "LICENSE" "run.sh" &>/dev/null

rm -rf .git
rm install.sh

bash "run.sh"
