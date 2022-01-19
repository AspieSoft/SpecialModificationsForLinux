#!/bin/bash

source ./bin/scripts/functions/common.sh

function fix_getOpts() {
  local fixDualMonitor=$(ynInput "Would you like to fix potential dual monitor issues with nvidia" "y")

  echo "$fixDualMonitor"

  unset fixDualMonitor
}


function fix_run() {
  bash ./bin/scripts/run/fix-common-issues.sh $1 $2
}


function fix_run_basic() {
  local opts=$(fix_getOpts)

  loading=$(startLoading "Fixing Common Apt Issues")
  (
    sudo killall apt apt-get &>/dev/null
    sudo dpkg --configure -a &>/dev/null
    sudo apt -y --fix-broken install &>/dev/null

    endLoading "$loading"
  ) &
  runLoading "$loading"

  runUpdate "true"
  fix_run "$opts"
  runUpdate

  unset opts
}
