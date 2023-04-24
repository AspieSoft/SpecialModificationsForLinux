#!/bin/bash

doneUpdate="$1"
updateMSG="$2"


if [ -z "$updateMSG" ] ; then
  updateMSG=""
fi


function cleanup() {
  tput cnorm
}
trap cleanup EXIT
tput civis


loadMode=0
while true ; do

  done=$(cat $doneUpdate)
  if [ "$done" = "true" ] ; then
    break
  fi

  if [ "$loadMode" -eq "0" ] ; then
    printf "\r$updateMSG|"
    loadMode=1
  elif [ "$loadMode" -eq "1" ] ; then
    printf "\r$updateMSG/"
    loadMode=2
  elif [ "$loadMode" -eq "2" ] ; then
    printf "\r$updateMSG—"
    loadMode=3
  elif [ "$loadMode" -eq "3" ] ; then
    printf "\r$updateMSG\\"
    loadMode=0
  fi

  sleep 0.25
done

tput cnorm

