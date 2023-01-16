#!/bin/bash

# sysMemory=$(grep MemTotal /proc/meminfo | sed -r 's/[^0-9]//g')
sysMemory=$(grep MemAvailable /proc/meminfo | sed -r 's/[^0-9]//g')

maxMem=$((sysMemory - 200000))

if [ "$maxMem" -lt "0" ]; then
  maxMem=$((sysMemory - 2000))
fi

if [ "$maxMem" -lt "0" ]; then
  maxMem=$((sysMemory - 200))
fi

if [ "$maxMem" -lt "0" ]; then
  maxMem="$sysMemory"
fi


if [ "$maxMem" -gt "0" ]; then
  ulimit -v "$maxMem"

  hasUlimit=$(grep "#SpecialModifications - MemLimit" "$HOME/.bashrc")

  if [[ "$hasUlimit" == "" ]]; then
    echo -e "\nulimit -v \"$maxMem\" #SpecialModifications - MemLimit\n" | sudo tee -a "$HOME/.bashrc" &>/dev/null
  else
    sudo sed -r -i "s/^(ulimit .*?)([\"'])[0-9]+\2(.*?#SpecialModifications - MemLimit)$/\1\2$maxMem\2\3/m" "$HOME/.bashrc" &>/dev/null
  fi
fi
