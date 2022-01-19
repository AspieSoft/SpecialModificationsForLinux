alias apti='sudo apt -y install'
alias aptrm='sudo apt autoremove'
alias aptu='sudo apt update'
alias aptup='sudo apt update; sudo apt upgrade -y'

function aptiu () {
  sudo apt -y install $@
  sudo apt update
}

function apt() {
  c="$1"
  p="${@:2}"
  if [ "$c" = "-y" ] ; then
    c="$2"
    p="${@:3}"
  fi

  if [ "$c" = "i" ] ; then
    sudo apt -y install $p
  elif [ "$c" = "iu" ] ; then
    sudo apt -y install $p
    sudo apt update
  elif [ "$c" = "rm" ] ; then
    sudo apt -y autoremove $p
  elif [ "$c" = "u" ] ; then
    sudo apt update
  elif [ "$c" = "up" ] ; then
    sudo apt update
    sudo apt upgrade -y
  elif [ -z "$c" -o "$c" = "-h" ] ; then
    sudo apt -h
    echo -e "i - install alias"
    echo -e "iu - install and update alias"
    echo -e "rm - autoremove alias"
    echo -e "u - update alias"
    echo -e "up - update and upgrade alias"
  else
    sudo apt $@
  fi
}


alias snapi='sudo snap -y install'
alias snaprm='sudo snap remove'
alias snapu='sudo snap refresh'
