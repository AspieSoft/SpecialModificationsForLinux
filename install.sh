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
if test -f "./bin/falcon.txt" ; then
  echo "$(cat ./bin/falcon.txt)"
else
  echo
fi
echo "Installer"
echo

sudo echo

echo
echo "Installing..."

# origDir=$(dirname "$0")
cd "$HOME"

if [ "$package_manager" = "apt" ]; then
  sudo apt -y install git &>/dev/null
elif [ "$package_manager" = "dnf" ]; then
  sudo dnf -y install git &>/dev/null
fi

rm -rf SpecialModificationsForLinux

# git clone -n --depth=1 --filter=tree:0 https://github.com/AspieSoft/SpecialModificationsForLinux.git &>/dev/null
# cd SpecialModificationsForLinux
# git sparse-checkout set --no-cone "/bin/common/" "/bin/scripts/main/" "/bin/scripts/$package_manager/" "/bin/falcon.txt" "/bin/printer-fix.png" "/readme.md" "/LICENSE" "/run.sh" &>/dev/null

mkdir SpecialModificationsForLinux
cd SpecialModificationsForLinux
git init &>/dev/null
git config core.sparseCheckout true
git remote add -f origin https://github.com/AspieSoft/SpecialModificationsForLinux.git &>/dev/null
echo "/bin/common/" >> ".git/info/sparse-checkout" &>/dev/null
echo "/bin/scripts/main/" >> ".git/info/sparse-checkout" &>/dev/null
echo "/bin/scripts/$package_manager/" >> ".git/info/sparse-checkout" &>/dev/null
echo "/bin/falcon.txt" >> ".git/info/sparse-checkout" &>/dev/null
echo "/bin/printer-fix.png" >> ".git/info/sparse-checkout" &>/dev/null
echo "/readme.md" >> ".git/info/sparse-checkout" &>/dev/null
echo "/LICENSE" >> ".git/info/sparse-checkout" &>/dev/null
echo "/run.sh" >> ".git/info/sparse-checkout" &>/dev/null
git checkout master &>/dev/null

rm -rf .git

if ! test -f "$HOME/.bash_aliases" ; then
  echo "" >> "$HOME/.bash_aliases"
fi

if ! sudo grep -q "# AspieSoft SpecialModifications Function" "$HOME/.bash_aliases" ; then
  echo "" >> "$HOME/.bash_aliases"
  echo "# AspieSoft SpecialModifications Function" >> "$HOME/.bash_aliases"
  echo "function SpecialModifications() {" >> "$HOME/.bash_aliases"
  echo '  cd "$HOME/SpecialModificationsForLinux"' >> "$HOME/.bash_aliases"
  echo '  bash "$HOME/SpecialModificationsForLinux/run.sh"' >> "$HOME/.bash_aliases"
  echo "}" >> "$HOME/.bash_aliases"
  echo "" >> "$HOME/.bash_aliases"
fi

echo
bash "run.sh"
