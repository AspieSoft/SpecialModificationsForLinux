#!/bin/bash

source ./bin/scripts/functions/common.sh

source ./bin/scripts/more/shortcuts.sh
source ./bin/scripts/fix.sh
source ./bin/scripts/more/upgrade.sh
source ./bin/scripts/more/apps.sh
source ./bin/scripts/more/p-languages.sh
source ./bin/scripts/more/security.sh


# To log into sudo with password prompt
sudo echo

# Get user input for GRUB_TIMEOUT (not making them wait for the script to get half way through)
grubTimeout=$(numberInput "What do you want to set the grub time to" "5" "0" "30" "Seconds")

shortcutOpts=$(shortcuts_getOpts)
fixOpts=$(fix_getOpts)
upgradeOpts=$(upgrade_getOpts)
appOpts=$(apps_getOpts)
pLangOpts=$(pLang_getOpts)

runScan=$(ynInput "Would you like to run a ClamAV Virus Scan afterwards" "n")


# enable firewall
loading=$(startLoading "Enabling Firewall")
(
  sudo ufw enable &>/dev/null
  endLoading "$loading"
) &
runLoading "$loading"


loading=$(startLoading "Fixing Common Apt Issues")
(
  sudo killall apt apt-get &>/dev/null
  sudo dpkg --configure -a &>/dev/null
  sudo apt -y --fix-broken install &>/dev/null

  endLoading "$loading"
) &
runLoading "$loading"


# update
runUpdate "true"


# install programing languages
pLang_run "$pLangOpts"


# update
runUpdate


# upgrade preformance
upgrade_run "$grubTimeout $upgradeOpts"

# fix common issues
fix_run "$fixOpts" "true"


# update
runUpdate


# install security
security_run

# install apps
apps_run "$appOpts"


# update
runUpdate


# add shortcuts
shortcuts_run "$shortcutOpts"


# update
runUpdate "true"


# clean ubuntu
loading=$(startLoading "Cleaning Up")
(
  sudo apt -y clean &>/dev/null
  sudo apt -y autoremove &>/dev/null
  sudo apt update &>/dev/null

  # unset variables
  unset grubTimeout

  unset shortcutOpts
  unset fixOpts
  unset upgradeOpts
  unset appOpts
  unset pLangOpts

  unset -f shortcuts_getOpts
  unset -f shortcuts_run
  unset -f fix_getOpts
  unset -f fix_run
  unset -f upgrade_getOpts
  unset -f upgrade_run
  unset -f apps_getOpts
  unset -f apps_run
  unset -f pLang_getOpts
  unset -f pLang_run

  endLoading "$loading"
) &
runLoading "$loading"
unset loading

echo -e "Done!\n"


# run virus scan
if [ "$runScan" = "true" ] ; then
  unset runScan
  bash ./bin/scripts/scan.sh "/"

  runUpdate
else
  unset runScan
fi
