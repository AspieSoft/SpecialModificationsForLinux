#!/bin/bash

source ./bin/scripts/functions/common.sh


loading=$(startLoading "Making Linux Drunk With WINE")
(
  sudo apt -y --install-recommends install wine-stable &>/dev/null

  #todo: get terminal name of zorinos windows app support
  #sudo apt -y install windows-app-support &>/dev/null

  endLoading "$loading"
) &
runLoading "$loading"
