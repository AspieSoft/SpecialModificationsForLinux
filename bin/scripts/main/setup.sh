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

  unset setNewTheme

  unset runScan

  unset setNewThemesReady
  unset setAppsReady

  # reset login timeout
  sudo sed -r -i 's/^Defaults([\t ]+)(.*)env_reset(.*), (timestamp_timeout=1801,?\s*)+$/Defaults\1\2env_reset\3/m' /etc/sudoers &>/dev/null

  # enable sleep
  sudo systemctl --runtime unmask sleep.target suspend.target hibernate.target hybrid-sleep.target &>/dev/null

  # enable auto updates
  if [ "$package_manager" = "apt" ]; then
    sudo sed -r -i 's/^APT::Periodic::Update-Package-Lists "([0-9]+)";$/APT::Periodic::Update-Package-Lists "1";/m' /etc/apt/apt.conf.d/20auto-upgrades &>/dev/null
    sudo sed -r -i 's/^APT::Periodic::Unattended-Upgrade "([0-9]+)";$/APT::Periodic::Unattended-Upgrade "1";/m' /etc/apt/apt.conf.d/20auto-upgrades &>/dev/null
  else
    gsettings set org.gnome.software download-updates true
  fi

  unset package_manager
}
trap cleanup EXIT


# To log into sudo with password prompt
sudo echo

# extend login timeout
sudo sed -r -i 's/^Defaults([\t ]+)(.*)env_reset(.*)$/Defaults\1\2env_reset\3, timestamp_timeout=1801/m' /etc/sudoers &>/dev/null

# disable sleep
sudo systemctl --runtime mask sleep.target suspend.target hibernate.target hybrid-sleep.target &>/dev/null

# disable auto updates
if [ "$package_manager" = "apt" ]; then
  sudo sed -r -i 's/^APT::Periodic::Update-Package-Lists "([0-9]+)";$/APT::Periodic::Update-Package-Lists "0";/m' /etc/apt/apt.conf.d/20auto-upgrades &>/dev/null
  sudo sed -r -i 's/^APT::Periodic::Unattended-Upgrade "([0-9]+)";$/APT::Periodic::Unattended-Upgrade "0";/m' /etc/apt/apt.conf.d/20auto-upgrades &>/dev/null
else
  gsettings set org.gnome.software download-updates false
fi

# Get user inputs
grubTimeout=$(numberInput "What do you want to set the grub time to" "5" "0" "30" "Seconds")

grubBadRam=$(ynInput "Would you like to Enable BadRAM Filtering" "y")

if [ "$package_manager" = "apt" ]; then
  disableUbuntuErrorReporting=$(ynInput "Would you like to Disable Ubuntu Error Reporting" "y")
else
  disableUbuntuErrorReporting="false"
fi

installNemo=$(ynInput "Would you like to Install The Nemo File Manager" "y")
installWine=$(ynInput "Would you like to Install WINE" "y")

if [ "$package_manager" = "apt" ]; then
  installIce=$(ynInput "Would you like to Install ICE" "y")
else
  installIce="false"
fi

if [ "$package_manager" = "apt" ]; then
  installKeyboardCursor=$(ynInput "Would you like to Install Aspiesoft Keyboard Cursor [CapsLock to enable, arrow keys to move mouse]" "n")
else
  installKeyboardCursor="false"
fi

installRecommended=$(ynInput "Would you like to Install Other Recommended Apps" "y")

#installExtras=$(ynInput "Would you like to Install Ubuntu Restricted Extras" "y")
installExtras="false"

if [ "$package_manager" = "apt" ]; then
  installOracleJava=$(ynInput "Would you like to Install Oracle Java 17" "y")
else
  installOracleJava="false"
fi

if [ "$package_manager" = "dnf" ]; then
  setNewTheme=$(ynInput "Would you like to change the theme and install gnome extentions" "n")
fi

runScan=$(ynInput "Would you like to run a ClamAV Virus Scan afterwards" "n")

echo

# fix clock to 12h format
gsettings set org.gnome.desktop.interface clock-format 12h &>/dev/null

if [ "$package_manager" = "dnf" ]; then
  # improve dnf preformance
  echo "# Added for Speed" | sudo tee -a /etc/dnf/dnf.conf &>/dev/null
  echo "fastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf &>/dev/null
  echo "max_parallel_downloads=5" | sudo tee -a /etc/dnf/dnf.conf &>/dev/null
  echo "defaultyes=True" | sudo tee -a /etc/dnf/dnf.conf &>/dev/null
  echo "keepcache=True" | sudo tee -a /etc/dnf/dnf.conf &>/dev/null
fi

if [ "$package_manager" = "apt" ]; then
  # enable firewall
  loading=$(startLoading "Enabling Firewall")
  (
    sudo ufw enable &>/dev/null
    endLoading "$loading"
  ) &
  runLoading "$loading"

  # fix possible apt issues
  loading=$(startLoading "Fixing Common Apt Issues")
  (
    sudo killall apt apt-get &>/dev/null
    sudo dpkg --configure -a &>/dev/null
    sudo apt -y --fix-broken install &>/dev/null

    endLoading "$loading"
  ) &
  runLoading "$loading"
fi

# update
runUpdate "true"


if [ "$package_manager" = "dnf" ]; then
  # swap and enable ufw firewall
  sudo dnf -y install ufw &>/dev/null

  sudo systemctl stop firewalld &>/dev/null
  sudo systemctl disable firewalld &>/dev/null

  sudo systemctl enable ufw &>/dev/null
  sudo systemctl start ufw &>/dev/null
  sudo ufw enable &>/dev/null

  # remove fedora default allow ssh
  sudo ufw delete allow SSH &>/dev/null
  sudo ufw delete allow to 224.0.0.251 app mDNS &>/dev/null
  sudo ufw delete allow to ff02::fb app mDNS &>/dev/null

  # update
  runUpdate

  sudo dnf -y makecache &>/dev/null
fi


# async download themes
if [ "$setNewTheme" = "true" ]; then
  setNewThemesReady="false"
  (
    bash "./bin/scripts/main/download-themes.sh" "$package_manager"
    setNewThemesReady="true"
  ) &
fi


# async download apps
setAppsReady="false"
(
  bash "./bin/scripts/main/download-apps.sh" "$package_manager"
  setAppsReady="true"
) &


bash "./bin/scripts/$package_manager/programing-languages.sh" "$installExtras" "$installOracleJava"

# update
runUpdate

bash "./bin/scripts/$package_manager/preformance.sh" "$grubTimeout" "$grubBadRam" "$disableUbuntuErrorReporting"

# fix common issues
bash ./bin/scripts/main/fix.sh "true"

# update
runUpdate

# wait for apps to finish installing
if [ "$setAppsReady" = "false" ]; then
  loading=$(startLoading "Waiting For Apps To Install")
  (
    while [ "$setAppsReady" = "false" ]; do
      if test -d ./bin/apps; then
        sleep 5
        break
      fi
      sleep 1
    done

    endLoading "$loading"
  ) &
  runLoading "$loading"
fi
sleep 1

# install security
bash "./bin/scripts/$package_manager/security.sh"

# install apps
bash "./bin/scripts/$package_manager/apps.sh" "$installNemo" "$installWine" "$installIce" "$installKeyboardCursor" "$installRecommended"

if [ "$package_manager" = "apt" ]; then
  # update
  runUpdate

  # install terminal shortcuts
  bash "./bin/scripts/$package_manager/shortcuts.sh"
fi

# update
runUpdate "true"

if [ "$package_manager" = "apt" ]; then
  sudo apt-get -y autoremove &>/dev/null

  # run virus scan
  if [ "$runScan" = "true" ] ; then
    bash ./bin/scripts/main/virus-scan.sh "/"

    runUpdate

    sudo apt-get -y autoremove &>/dev/null
  fi
elif [ "$package_manager" = "dnf" ]; then
  sudo dnf clean all &>/dev/null

  # run virus scan
  if [ "$runScan" = "true" ] ; then
    bash ./bin/scripts/main/virus-scan.sh "/"

    runUpdate

    sudo dnf clean all &>/dev/null
  fi

  if [ "$setNewTheme" = "true" ]; then
    # wait for themes to finish installing
    if [ "$setNewThemesReady" = "false" ]; then
      loading=$(startLoading "Waiting For Themes To Install")
      (
        while [ "$setNewThemesReady" = "false" ]; do
          if test -d ./bin/themes; then
            sleep 5
            break
          fi
          sleep 1
        done

        endLoading "$loading"
      ) &
      runLoading "$loading"
    fi
    sleep 1

    bash ./bin/scripts/$package_manager/theme.sh
  fi
fi
