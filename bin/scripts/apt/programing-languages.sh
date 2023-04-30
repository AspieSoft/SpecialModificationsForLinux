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


# install extras
sudo apt -y install ubuntu-restricted-extras
# if [ "$installExtras" = true ] ; then
#   loading=$(startLoading "Installing Ubuntu Extras")
#   (
#     #todo: prevent need to confirm license
#     sudo apt -y install ubuntu-restricted-extras &>/dev/null
# 
#     endLoading "$loading"
#   ) &
#   runLoading "$loading"
# fi


# install python
loading=$(startLoading "Installing Python")
(
  sudo apt -y install python &>/dev/null
  sudo apt -y install python3 &>/dev/null

  sudo apt -y install python-pip &>/dev/null
  sudo apt -y install python3-pip &>/dev/null

  endLoading "$loading"
) &
runLoading "$loading"


# install java
loading=$(startLoading "Installing Java")
(
  sudo apt -y install openjdk-8-jre &>/dev/null
  sudo apt -y install openjdk-8-jdk &>/dev/null

  sudo apt -y install openjdk-11-jre &>/dev/null
  sudo apt -y install openjdk-11-jdk &>/dev/null

  if [ "$installOracleJava" = true ] ; then
    if [ $(hasPackage "oracle-java17-installer") = "false" ] ; then
      sudo add-apt-repository -y ppa:linuxuprising/java &>/dev/null
      sudo apt update &>/dev/null

      sudo echo oracle-java17-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections

      sudo echo oracle-java17-installer shared/accepted-oracle-license-v1-2 select true | sudo /usr/bin/debconf-set-selections

      sudo echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
      sudo echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections

      sudo echo debconf shared/accepted-oracle-license-v1-2 select true | sudo debconf-set-selections
      sudo echo debconf shared/accepted-oracle-license-v1-2 seen true | sudo debconf-set-selections

      sudo apt -y install oracle-java17-installer --install-recommends &>/dev/null
    fi
  fi

  endLoading "$loading"
) &
runLoading "$loading"


# install node.js
loading=$(startLoading "Installing Node.js")
(
  sudo apt -y install curl dirmngr apt-transport-https lsb-release ca-certificates &>/dev/null
  curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash - &>/dev/null

  sudo apt -y install nodejs &>/dev/null

  sudo apt -y install gcc &>/dev/null
  sudo apt -y install g++ &>/dev/null
  sudo apt -y install make &>/dev/null

  endLoading "$loading"
) &
runLoading "$loading"

# install npm
loading=$(startLoading "Installing NPM")
(
  sudo apt -y install npm &>/dev/null

  npm config set prefix ~/.npm

  if ! [ -f "$HOME/.zshrc" ]; then
    sudo touch "$HOME/.zshrc" &>/dev/null
  fi

  if ! [ -f "/etc/skel/.zshrc" ]; then
    sudo touch "/etc/skel/.zshrc" &>/dev/null
  fi

  if ! [ -f "$HOME/.profile" ]; then
    sudo touch "$HOME/.profile" &>/dev/null
  fi

  if ! [ -f "/etc/skel/.profile" ]; then
    sudo touch "/etc/skel/.profile" &>/dev/null
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

  sudo npm install -g npm &>/dev/null

  sudo mkdir $(whoami) ~/.npm &>/dev/null
  sudo chown -R $(whoami) ~/.npm

  endLoading "$loading"
) &
runLoading "$loading"

# install yarn
loading=$(startLoading "Installing YARN")
(
  sudo apt -y install yarn &>/dev/null

  endLoading "$loading"
) &
runLoading "$loading"


# install git
loading=$(startLoading "Installing GIT")
(
  sudo apt -y install git &>/dev/null

  endLoading "$loading"
) &
runLoading "$loading"


# install go
loading=$(startLoading "Go Go Gaget Install Golang")
(
  goVersion=$(curl -sL https://golang.org/VERSION?m=text)
  wget -L "https://dl.google.com/go/${goVersion}.linux-amd64.tar.gz" &>/dev/null

  goSum=$(curl -sL https://golang.org/dl/ | grep -A 5 -w "${goVersion}.linux-amd64.tar.gz" | grep "<td><tt>")
  goSum=$(echo "$goSum" | sed -e 's/^.*<td><tt>//' -e 's#</tt></td>.*$##' -e 's/[^A-Za-z0-9]//')
  goSum=$(echo "$goSum *${goVersion}.linux-amd64.tar.gz" | shasum -a 256 --check | grep "${goVersion}.linux-amd64.tar.gz: OK")

  if [[ "$goSum" != "" ]]; then
    sudo rm -rf /usr/share/go
    sudo tar -C /usr/share -xzf "${goVersion}.linux-amd64.tar.gz"

    hasExport=$(sudo grep "export GOROOT=" "$HOME/.bashrc")
    if [[ "$hasExport" == "" ]]; then
      echo -e '\nexport GOROOT=/usr/share/go\nexport GOPATH=$HOME/go\nexport PATH=$GOPATH/bin:$GOROOT/bin:$PATH\n' | sudo tee -a "$HOME/.bashrc" &>/dev/null
    fi

    hasExport=$(sudo grep "export GOROOT=" "/etc/skel/.bashrc")
    if [[ "$hasExport" == "" ]]; then
      echo -e '\nexport GOROOT=/usr/share/go\nexport GOPATH=$HOME/go\nexport PATH=$GOPATH/bin:$GOROOT/bin:$PATH\n' | sudo tee -a /etc/skel/.bashrc &>/dev/null
    fi

    unset hasExport
  fi

  sudo rm -rf "${goVersion}.linux-amd64.tar.gz"

  unset goVersion
  unset goSum

  endLoading "$loading"
) &
runLoading "$loading"
