#!/bin/bash

function startLoading() {
  local tempVar=$(mktemp) && echo "false" > $tempVar
  echo "$tempVar" "$1"
  unset tempVar
}

function runLoading() {
  local path=$(echo "$1" | cut -d' ' -f1)
  local msg="${1#* }"
  bash ./bin/common/loading.sh "$path" "$msg..."
}

function endLoading() {
  local path=$(echo "$1" | cut -d' ' -f1)
  local msg="${1#* }"
  echo "true" > $path
  echo -e "\r$msg    \n"
  unset path
  unset msg
}

function runUpdate() {
  local loading=$(startLoading "Updating")
  (
    sudo apt update &>/dev/null
    if [ "$1" = "true" ] ; then
      sudo apt upgrade -y &>/dev/null
    fi
    endLoading "$loading"
  ) &
  runLoading "$loading"
  unset loading
}

function numberInput() {

  local def="$2"
  local min="$3"
  local max="$4"
  local unit=" $5"

  if [ -n "$min" ] && ! [ "$min" -eq "$min" ] 2>/dev/null; then
    min=1
  fi
  if [ -n "$max" ] && ! [ "$max" -eq "$max" ] 2>/dev/null; then
    max=10
  fi
  if [ -n "$def" ] && ! [ "$def" -eq "$def" ] 2>/dev/null; then
    def=$min
  fi
  if [ $min -gt $max ] ; then
    local temp=$max
    max=$min
    min=$temp
    unset temp
  fi

  if [ "$unit" = " " ] ; then
    unit=""
  fi

  local input=""
  read -p "$1 ($min-$max$unit)? " input
  if [ -n "$input" ] && ! [ "$input" -eq "$input" ] 2>/dev/null; then
    input=$def
  fi

  if [ $input -lt $min ] ; then
    input=$min
  fi
  if [ $input -gt $max ] ; then
    input=$max
  fi

  echo "$input"
  echo -e "$input\n" >&2

  unset input
  unset min
  unset max
  unset def
  unset unit
}

function ynInput() {

  local optY="y"
  local optN="n"

  if [ "$2" = "y" -o "$2" = "Y" ] ; then
    optY="Y"
  elif [ "$2" = "n" -o "$2" = "N" ] ; then
    optN="N"
  fi

  local input=""
  read -n1 -p "$1 ($optY/$optN)? " input ; echo >&2

  if [ "$input" = "y" -o "$input" = "Y" ] ; then
    echo "true"
  elif [ "$input" = "n" -o "$input" = "N" ] ; then
    echo "false"
  else
    if [ "$2" = "y" -o "$2" = "Y" ] ; then
      echo "true"
    elif [ "$2" = "n" -o "$2" = "N" ] ; then
      echo "false"
    else
      echo ynInput "$1" "$2"
    fi
  fi

  unset input
  unset optY
  unset optN
}

function hasPackage() {
  local installed=$(dpkg-query -W --showformat='${Status}\n' $1 2>/dev/null|grep "install ok installed") &>/dev/null

  if [ "$installed" = "" ] ; then
    echo "false"
  else
    echo "true"
  fi

  unset installed
}
