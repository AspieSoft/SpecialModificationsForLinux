#!/bin/bash

source ./bin/scripts/functions/common.sh


function security_run() {
  bash ./bin/scripts/run/install-security.sh
}


function security_run_basic() {
  read -p "What Directory would you like to Scan with ClamAV? " scanDir

  runUpdate "true"
  security_run
  runUpdate

  unset -f security_run

  bash ./bin/scripts/scan.sh "$scanDir"

  unset scanDir
}
