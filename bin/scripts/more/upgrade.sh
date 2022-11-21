#!/bin/bash

source ./bin/scripts/functions/common.sh

function upgrade_getOpts() {
  local grubBadRam=$(ynInput "Would you like to Enable BadRAM Filtering" "n")
  local disableUbuntuErrorReporting=$(ynInput "Would you like to Disable Ubuntu Error Reporting" "y")

  echo "$grubBadRam $disableUbuntuErrorReporting"

  unset grubBadRam
  unset disableUbuntuErrorReporting
}


function upgrade_run() {
  bash ./bin/scripts/run/upgrade-preformance.sh $1
}


function upgrade_run_basic() {
  local grubTimeout=$(numberInput "What do you want to set the grub time to" "5" "0" "30" "Seconds")

  local opts=$(upgrade_getOpts)
  runUpdate "true"
  upgrade_run "$grubTimeout $opts"
  runUpdate

  unset opts
  unset grubTimeout
}
