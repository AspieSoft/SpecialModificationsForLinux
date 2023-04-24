#!/bin/bash

source ./bin/common/functions.sh

function cleanup() {
  unset loading

  unset grubTimeout

  unset grubBadRam
  unset disableUbuntuErrorReporting

  unset installNemo
  unset installWine
  unset installIce
  unset installKeyboardCursor
  unset installRecommended

  #unset installExtras
  unset installOracleJava

  unset runScan

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


# Get user inputs
grubTimeout=$(numberInput "What do you want to set the grub time to" "5" "0" "30" "Seconds")

grubBadRam=$(ynInput "Would you like to Enable BadRAM Filtering" "y")
disableUbuntuErrorReporting=$(ynInput "Would you like to Disable Ubuntu Error Reporting" "y")

installNemo=$(ynInput "Would you like to Install The Nemo File Manager" "y")
installWine=$(ynInput "Would you like to Install WINE" "y")
installIce=$(ynInput "Would you like to Install ICE" "y")
installKeyboardCursor=$(ynInput "Would you like to Install Aspiesoft Keyboard Cursor [CapsLock to enable, arrow keys to move mouse]" "n")
installRecommended=$(ynInput "Would you like to Install Other Recommended Apps" "y")

#installExtras=$(ynInput "Would you like to Install Ubuntu Restricted Extras" "y")
installOracleJava=$(ynInput "Would you like to Install Oracle Java 17" "y")

runScan=$(ynInput "Would you like to run a ClamAV Virus Scan afterwards" "n")

echo

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

#bash ./bin/scripts/setup/programing-languages.sh "$installExtras" "$installOracleJava"
bash ./bin/scripts/setup/programing-languages.sh "$installOracleJava"

# update
runUpdate

bash ./bin/scripts/setup/preformance.sh "$grubTimeout" "$grubBadRam" "$disableUbuntuErrorReporting"

# fix common issues
bash ./bin/scripts/fix.sh "true"

# update
runUpdate

# install security
bash ./bin/scripts/setup/security.sh

# install apps
bash ./bin/scripts/setup/apps.sh "$installNemo" "$installWine" "$installIce" "$installKeyboardCursor" "$installRecommended"

# update
runUpdate

# install terminal shortcuts
bash ./bin/scripts/setup/shortcuts.sh

# update
runUpdate "true"

sudo apt-get -y autoremove &>/dev/null

# run virus scan
if [ "$runScan" = "true" ] ; then
  bash ./bin/scripts/virus-scan.sh "/"

  runUpdate

  sudo apt-get -y autoremove &>/dev/null
fi
