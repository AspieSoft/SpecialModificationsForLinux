#!/bin/bash

source ./bin/scripts/functions/common.sh

function shortcuts_getOpts() {
  local addYumAlias=$(ynInput "Would you like to make yum an alias of apt" "y")

  echo "$addYumAlias"

  unset addYumAlias
}


function shortcuts_run() {
  bash ./bin/scripts/run/install-shortcuts.sh $1
}


function shortcuts_run_basic() {
  local opts=$(shortcuts_getOpts)
  runUpdate "true"
  shortcuts_run "$opts"
  runUpdate

  unset opts
}
