#!/bin/bash

source ./bin/scripts/functions/common.sh

function apps_getOpts() {
  local installNemo=$(ynInput "Would you like to Install The Nemo File Manager" "y")
  local installWine=$(ynInput "Would you like to Install WINE" "y")
  local installIce=$(ynInput "Would you like to Install ICE" "y")
  local installRecommended=$(ynInput "Would you like to Install Recommended Apps" "y")
  local installKeyboardCursor=$(ynInput "Would you like to Install Aspiesoft Keyboard Cursor [CapsLock to enable, arrow keys to move mouse]" "n")
  # local installExtras=$(ynInput "Would you like to Install Ubuntu Restricted Extras" "y")

  # echo "$installNemo $installWine $installIce $installRecommended $installKeyboardCursor $installExtras"
  echo "$installNemo $installWine $installIce $installRecommended $installKeyboardCursor"

  unset installNemo
  unset installWine
  unset installIce
  unset installRecommended
  unset installExtras
}


function apps_run() {
  bash ./bin/scripts/run/install-apps.sh $1
}


function apps_run_basic() {
  local opts=$(apps_getOpts)
  runUpdate "true"
  apps_run "$opts"
  runUpdate

  unset opts
}
