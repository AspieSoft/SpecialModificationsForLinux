#!/bin/bash

source ./bin/scripts/functions/common.sh

function cleanup() {
  unset loading

  unset installOracleJava
}
trap cleanup EXIT

installOracleJava="$1"


# hide basic folders
loading=$(startLoading "Hiding 'core' and 'snap' Folders")
(
  if ! [ ! -z $(grep "core" "$HOME/.hidden") ] ; then
    echo 'core' | sudo tee -a $HOME/.hidden &>/dev/null
  fi

  if ! [ ! -z $(grep "snap" "$HOME/.hidden") ] ; then
    echo 'snap' | sudo tee -a $HOME/.hidden &>/dev/null
  fi

  # for new users
  if ! [ ! -z $(grep "core" "/etc/skel/.hidden") ] ; then
    echo 'core' | sudo tee -a /etc/skel/.hidden &>/dev/null
  fi

  if ! [ ! -z $(grep "snap" "/etc/skel/.hidden") ] ; then
    echo 'snap' | sudo tee -a /etc/skel/.hidden &>/dev/null
  fi

  endLoading "$loading"
) &
runLoading "$loading"


# install java
loading=$(startLoading "Installing Java")
(
  if [ $(hasPackage "openjdk-8-jre") = "false" ] ; then
    sudo apt -y install openjdk-8-jre &>/dev/null
  fi
  if [ $(hasPackage "openjdk-8-jdk") = "false" ] ; then
    sudo apt -y install openjdk-8-jdk &>/dev/null
  fi

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
  else
    if [ $(hasPackage "openjdk-11-jre") = "false" ] ; then
      sudo apt -y install openjdk-11-jre &>/dev/null
    fi
    if [ $(hasPackage "openjdk-11-jdk") = "false" ] ; then
      sudo apt -y install openjdk-11-jdk &>/dev/null
    fi
  fi

  endLoading "$loading"
) &
runLoading "$loading"


# install python
loading=$(startLoading "Installing Python")
(
  if [ $(hasPackage "python") = "false" ] ; then
    sudo apt -y install python &>/dev/null
  fi

  if [ $(hasPackage "python3") = "false" ] ; then
    sudo apt -y install python3 &>/dev/null
  fi

  endLoading "$loading"
) &
runLoading "$loading"


# install node.js
loading=$(startLoading "Installing Node.js")
(
  sudo apt -y install curl dirmngr apt-transport-https lsb-release ca-certificates &>/dev/null
  curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash - &>/dev/null

  if [ $(hasPackage "nodejs") = "false" ] ; then
    sudo apt -y install nodejs &>/dev/null
  fi

  if [ $(hasPackage "gcc") = "false" ] ; then
    sudo apt -y install gcc &>/dev/null
  fi
  if [ $(hasPackage "g++") = "false" ] ; then
    sudo apt -y install g++ &>/dev/null
  fi
  if [ $(hasPackage "make") = "false" ] ; then
    sudo apt -y install make &>/dev/null
  fi

  endLoading "$loading"
) &
runLoading "$loading"


# install npm
loading=$(startLoading "Installing NPM")
(
  if [ $(hasPackage "npm") = "false" ] ; then
    sudo apt -y install npm &>/dev/null
  fi

  npm config set prefix ~/.npm
  echo 'export N_PREFIX="$HOME/.npm"' >> ~/.zshrc
  echo 'export N_PREFIX="$HOME/.npm"' >> ~/.profile

  sudo npm install -g npm &>/dev/null

  sudo mkdir $(whoami) ~/.npm &>/dev/null
  sudo chown -R $(whoami) ~/.npm

  endLoading "$loading"
) &
runLoading "$loading"


# install yarn
loading=$(startLoading "Installing YARN")
(
  if [ $(hasPackage "yarn") = "false" ] ; then
    sudo apt -y install yarn &>/dev/null
  fi

  endLoading "$loading"
) &
runLoading "$loading"


# install git
loading=$(startLoading "Installing GIT")
(
  if [ $(hasPackage "git") = "false" ] ; then
    sudo apt -y install git &>/dev/null
  fi

  endLoading "$loading"
) &
runLoading "$loading"


# install go
loading=$(startLoading "Go Go Gaget Install Golang")
(
  if [ $(hasPackage "golang-go") = "false" ] ; then
    sudo apt -y install golang-go &>/dev/null
  fi

  if ! [ ! -z $(grep "go" "$HOME/.hidden") ] ; then
    echo 'go' | sudo tee -a $HOME/.hidden &>/dev/null
  fi

  # for new users
  if ! [ ! -z $(grep "go" "/etc/skel/.hidden") ] ; then
    echo 'go' | sudo tee -a /etc/skel/.hidden &>/dev/null
  fi

  endLoading "$loading"
) &
runLoading "$loading"


unset loading
