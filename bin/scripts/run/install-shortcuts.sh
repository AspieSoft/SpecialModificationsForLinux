#!/bin/bash

source ./bin/scripts/functions/common.sh

function cleanup() {
  unset loading
  unset addYumAlias
}
trap cleanup EXIT

addYumAlias="$1"


loading=$(startLoading "Installing Custom Aliases")
(

  if sudo grep -q "# AspieSoft Added Aliases" /etc/bash.bashrc ; then
    # todo: fix isue where this is not removed (regex failed)
    sudo sed -r -i -z "s/# AspieSoft Added Aliases - START\r?\n([\r\n]|.)*?\r?\n# AspieSoft Added Aliases - END//m" /etc/default/grub &>/dev/null
  else
    sudo cp /etc/bash.bashrc /etc/bash.bashrc-backup &>/dev/null
  fi


  echo -e "\n# AspieSoft Added Aliases - START\n" | sudo tee -a /etc/bash.bashrc &>/dev/null

  sudo cat ./bin/apps/aspiesoft-aliases/install-aliases.sh | sudo tee -a /etc/bash.bashrc &>/dev/null

  if [ "$addYumAlias" = true ] ; then
    sudo cat ./bin/apps/aspiesoft-aliases/install-yum-aliases.sh | sudo tee -a /etc/bash.bashrc &>/dev/null
  fi

  echo -e "\n# AspieSoft Added Aliases - END\n" | sudo tee -a /etc/bash.bashrc &>/dev/null


  endLoading "$loading"
) &
runLoading "$loading"
