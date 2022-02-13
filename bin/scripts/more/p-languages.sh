#!/bin/bash

source ./bin/scripts/functions/common.sh

function pLang_getOpts() {
  local installOracleJava=$(ynInput "Would you like to Install Oracle Java 17" "y")

  echo "$installOracleJava"

  unset installOracleJava
}


function pLang_run() {
  bash ./bin/scripts/run/install-programing-languages.sh $1
}


function pLang_run_basic() {
  local opts=$(pLang_getOpts)
  runUpdate "true"
  pLang_run "$opts"
  runUpdate

  unset opts
}
