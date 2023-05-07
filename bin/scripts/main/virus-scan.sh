#!/bin/bash

source ./bin/common/functions.sh

function cleanup() {
  unset loading
}
trap cleanup EXIT

scanDir="$1"

if [ -z "$scanDir" ] ; then
  read -p "What Directory would you like to Scan with ClamAV? " scanDir

  if [ -z "$scanDir" ] ; then
    scanDir="/"
  fi
fi


echo "" >> scan.log

echo
echo "Scanning for viruses..."

scanFinished=$(mktemp) && echo "false" >$scanFinished
(
  sudo nice -n 15 clamscan &>/dev/null
  sudo clamscan -r --bell --move="/VirusScan/quarantine" --exclude-dir="/VirusScan/quarantine" --exclude-dir="/home/$USER/.clamtk/viruses" --exclude-dir="smb4k" --exclude-dir="/run/user/$USER/gvfs" --exclude-dir="/home/$USER/.gvfs" --exclude-dir=".thunderbird" --exclude-dir=".mozilla-thunderbird" --exclude-dir=".evolution" --exclude-dir="Mail" --exclude-dir="kmail" --exclude-dir="^/sys" $scanDir &> scan.log && echo "true" > $scanFinished
) &

tempFileCount=$(mktemp) && echo "false" >$tempFileCount
(echo $(sudo ls --ignore="/VirusScan/quarantine" --ignore="/home/$USER/.clamtk/viruses" --ignore="smb4k" --ignore="/run/user/$USER/gvfs" --ignore="/home/$USER/.gvfs" --ignore=".thunderbird" --ignore=".mozilla-thunderbird" --ignore=".evolution" --ignore="Mail" --ignore="kmail" --ignore="^/sys" -l -R $scanDir | grep ^- | awk '{print $9}' | wc -l) > $tempFileCount) &

scanLoopTimeout=43200 # 12 hours
scanLoopMode=0


function cleanup() {
  tput cnorm
}
trap cleanup EXIT
tput civis


loadingLine="|"
# loadingLine="🕛"


while true ; do

  scanLoopTimeout=$(($scanLoopTimeout-1))

  if [ "$scanLoopTimeout" -lt "0" ] ; then
    echo -e "\nProgress Tracker Timed Out!\n"
    break
  fi

  if [ "$loadingLine" = "|" ]; then
    loadingLine="/"
  elif [ "$loadingLine" = "/" ]; then
    loadingLine="-"
  elif [ "$loadingLine" = "-" ]; then
    loadingLine="\\"
  elif [ "$loadingLine" = "\\" ]; then
    loadingLine="|"
  fi

  # if [ "$loadingLine" = "🕛" ]; then
  #   loadingLine="🕐"
  # elif [ "$loadingLine" = "🕐" ]; then
  #   loadingLine="🕑"
  # elif [ "$loadingLine" = "🕑" ]; then
  #   loadingLine="🕒"
  # elif [ "$loadingLine" = "🕒" ]; then
  #   loadingLine="🕓"
  # elif [ "$loadingLine" = "🕓" ]; then
  #   loadingLine="🕔"
  # elif [ "$loadingLine" = "🕔" ]; then
  #   loadingLine="🕕"
  # elif [ "$loadingLine" = "🕕" ]; then
  #   loadingLine="🕖"
  # elif [ "$loadingLine" = "🕖" ]; then
  #   loadingLine="🕗"
  # elif [ "$loadingLine" = "🕗" ]; then
  #   loadingLine="🕘"
  # elif [ "$loadingLine" = "🕘" ]; then
  #   loadingLine="🕙"
  # elif [ "$loadingLine" = "🕙" ]; then
  #   loadingLine="🕚"
  # elif [ "$loadingLine" = "🕚" ]; then
  #   loadingLine="🕛"
  # fi

  doneScan=$(cat $scanFinished)
  fileCount=$(cat $tempFileCount)

  if [ "$doneScan" = "true" ] ; then
    if ! [ "$fileCount" = "false" ] ; then
      # printf "\rProgress : [#########################] 100%%     "
      printf "\rProgress $loadingLine [#########################] 100%%     "
    fi
    break
  fi

  if [ "$fileCount" = "false" ] ; then

    if [ "$scanLoopMode" -eq "0" ] ; then
      printf "\r|"
      scanLoopMode=1
    elif [ "$scanLoopMode" -eq "1" ] ; then
      printf "\r/"
      scanLoopMode=2
    elif [ "$scanLoopMode" -eq "2" ] ; then
      printf "\r-"
      scanLoopMode=3
    elif [ "$scanLoopMode" -eq "3" ] ; then
      printf "\r\\"
      scanLoopMode=0
    fi

    sleep 0.25
    continue
  fi

  scanCount=$(wc -l < scan.log)

  if [ "$scanCount" -gt "$fileCount" ] ; then
    # printf "\rProgress : [#########################] 100%%     "
    printf "\rProgress $loadingLine [#########################] 100%%     "
    break
  fi

  scanP25=$(($scanCount * 25 / $fileCount))
  scanP25M=$((25-$scanP25))
  scanPFill=$(printf "%${scanP25}s")
  scanPEmpt=$(printf "%${scanP25M}s")

  scanP100=$(($scanCount * 100 / $fileCount))

  # printf "\rProgress : [${scanPFill// /#}${scanPEmpt// /-}] ${scanP100}%%     "
  printf "\rProgress $loadingLine [${scanPFill// /#}${scanPEmpt// /-}] ${scanP100}%%     "

  sleep 1
done

tput cnorm

echo
echo -e "\nScan Finished!\n"

echo
read -p "Would you like to see the log (y/N)? " seeLogYN
if [ "$seeLogYN" = "y" -o "$seeLogYN" = "Y" ] ; then
  sudo gedit scan.log &
fi


# clean up
loading=$(startLoading "Cleaning Up")
(
  unset scanCount
  unset seeLogYN
  unset scanDir
  sudo rm -rf $scanFinished
  sudo rm -rf $tempFileCount
  unset scanFinished
  unset tempFileCount

  endLoading "$loading"
) &
runLoading "$loading"
unset loading

tput cnorm
