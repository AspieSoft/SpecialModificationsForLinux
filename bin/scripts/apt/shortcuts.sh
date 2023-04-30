#!/bin/bash

source ./bin/common/functions.sh

function cleanup() {
  unset loading
}
trap cleanup EXIT

loading=$(startLoading "Installing AspieSoft Terminal Shortcuts")
(
  if sudo grep -q "# AspieSoft Added Aliases" /etc/bash.bashrc ; then
    sudo sed -r -i -z "s/# AspieSoft Added Aliases - START\r?\n([\r\n]|.)*?\r?\n# AspieSoft Added Aliases - END//m" /etc/bash.bashrc &>/dev/null
  else
    sudo cp /etc/bash.bashrc /etc/bash.bashrc-backup &>/dev/null
  fi


  echo -e "\n# AspieSoft Added Aliases - START\n" | sudo tee -a /etc/bash.bashrc &>/dev/null

  sudo cat ./bin/apps/aspiesoft-terminal-shortcuts.sh | sudo tee -a /etc/bash.bashrc &>/dev/null

  echo -e "\n# AspieSoft Added Aliases - END\n" | sudo tee -a /etc/bash.bashrc &>/dev/null

  endLoading "$loading"
) &
runLoading "$loading"
