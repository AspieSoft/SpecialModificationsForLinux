alias yumi='sudo apt -y install'
alias yumrm='sudo apt autoremove'

function yum() {
  c="$1"
  p="${@:2}"
  if [ "$c" = "-y" ] ; then
    c="$2"
    p="${@:3}"
  fi

  if [ "$c" = "install" -o "$c" = "i" ] ; then
    sudo apt -y install $p
    sudo apt update
  elif [ "$c" = "remove" -o "$c" = "rm" ] ; then
    sudo apt autoremove $p
    sudo apt update
  else
    sudo apt $@
    sudo apt update
  fi
}
