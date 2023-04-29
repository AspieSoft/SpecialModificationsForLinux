#!/bin/bash

source ./bin/common/functions.sh

function cleanup() {
  unset loading

  #unset installExtras
  unset installOracleJava
}
trap cleanup EXIT

installExtras="$1"
installOracleJava="$2"


# install python
loading=$(startLoading "Installing Python")
(
  sudo dnf -y install python &>/dev/null
  sudo dnf -y install python3 &>/dev/null

  sudo dnf -y install python-pip &>/dev/null

  endLoading "$loading"
) &
runLoading "$loading"


# install c++
loading=$(startLoading "Installing C++")
(
  sudo dnf -y install gcc-c++ &>/dev/null
  sudo dnf -y install make gcc &>/dev/null

  endLoading "$loading"
) &
runLoading "$loading"


# install java
loading=$(startLoading "Installing Java")
(
  sudo dnf -y install java-1.8.0-openjdk.x86_64 &>/dev/null
  sudo dnf -y install java-11-openjdk.x86_64 &>/dev/null
  sudo dnf -y install java-latest-openjdk.x86_64 &>/dev/null

  #todo: add optional oracal java install
  # auto set to false for dnf
  # if [ "$installOracleJava" = true ] ; then
  #   if [ $(hasPackage "oracle-java17-installer") = "false" ] ; then
  #     sudo add-apt-repository -y ppa:linuxuprising/java &>/dev/null
  #     sudo apt update &>/dev/null

  #     sudo echo oracle-java17-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections

  #     sudo echo oracle-java17-installer shared/accepted-oracle-license-v1-2 select true | sudo /usr/bin/debconf-set-selections

  #     sudo echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
  #     sudo echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections

  #     sudo echo debconf shared/accepted-oracle-license-v1-2 select true | sudo debconf-set-selections
  #     sudo echo debconf shared/accepted-oracle-license-v1-2 seen true | sudo debconf-set-selections

  #     sudo apt -y install oracle-java17-installer --install-recommends &>/dev/null
  #   fi
  # fi

  endLoading "$loading"
) &
runLoading "$loading"


# install node.js
loading=$(startLoading "Installing Node.js")
(
  sudo dnf -y install nodejs &>/dev/null
  sudo npm -g i npm &>/dev/null
  npm config set prefix ~/.npm &>/dev/null

  if ! [ -f "$HOME/.zshrc" ]; then
    sudo touch "$HOME/.zshrc" &>/dev/null
  fi

  if ! [ -f "/etc/skel/.zshrc" ]; then
    sudo touch "/etc/skel/.zshrc" &>/dev/null
  fi

  hasExport=$(sudo grep 'export N_PREFIX="$HOME/.npm"' "$HOME/.zshrc")
  if [[ "$hasExport" == "" ]]; then
    echo 'export N_PREFIX="$HOME/.npm"' | sudo tee -a "$HOME/.zshrc" &>/dev/null
  fi

  hasExport=$(sudo grep 'export N_PREFIX="$HOME/.npm"' "$HOME/.profile")
  if [[ "$hasExport" == "" ]]; then
    echo 'export N_PREFIX="$HOME/.npm"' | sudo tee -a "$HOME/.profile" &>/dev/null
  fi

  hasExport=$(sudo grep 'export N_PREFIX="$HOME/.npm"' "/etc/skel/.zshrc")
  if [[ "$hasExport" == "" ]]; then
    echo 'export N_PREFIX="$HOME/.npm"' | sudo tee -a "/etc/skel/.zshrc" &>/dev/null
  fi

  hasExport=$(sudo grep 'export N_PREFIX="$HOME/.npm"' "/etc/skel/.profile")
  if [[ "$hasExport" == "" ]]; then
    echo 'export N_PREFIX="$HOME/.npm"' | sudo tee -a "/etc/skel/.profile" &>/dev/null
  fi

  unset hasExport

  sudo mkdir $(whoami) ~/.npm &>/dev/null
  sudo chown -R $(whoami) ~/.npm

  endLoading "$loading"
) &
runLoading "$loading"

# install yarn
loading=$(startLoading "Installing YARN")
(
  sudo npm -g i yarn

  endLoading "$loading"
) &
runLoading "$loading"


# install git
loading=$(startLoading "Installing GIT")
(
  if [ $(hasPackage "git") = "false" ] ; then
    sudo dnf -y install git &>/dev/null
  fi

  endLoading "$loading"
) &
runLoading "$loading"


# install go
loading=$(startLoading "Go Go Gaget Install Golang")
(
  sudo dnf -y install golang &>/dev/null

  endLoading "$loading"
) &
runLoading "$loading"
