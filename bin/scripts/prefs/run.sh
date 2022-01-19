#!/bin/bash

source ./bin/scripts/functions/common.sh

echo

installBasic=$(ynInput "Would you like us to configure basic settings including date/time" "y")
if [ "$installBasic" = "true" ] ; then
  installBasicIdleDelay=$(ynInput "Would you also like to set the idle delay to '900'" "y")
  installBasicTerminalName=$(ynInput "Would you also like to change the terminal PC display name to @zorinos" "y")
fi

installKeybind=$(ynInput "Would you like us to configure some of the keybinds" "y")

installTaskbar=$(ynInput "Would you like us to configure the taskbar" "y")
if [ "$installTaskbar" = "true" ] ; then
  installTaskbarIntellihide=$(ynInput "Would you also like to use intellihide on secondary monitors" "y")
fi

installGuake=$(ynInput "Would you like us to configure the guake terminal" "y")
if [ "$installGuake" = "true" ] ; then
  installGuakeKeybind=$(ynInput "Would you also like to set guake's toggle keybind to 'Menu'" "y")
fi


if [ "$installBasic" = "true" ] ; then
  loading=$(startLoading "Configuring Basic Settings")
  (
    bash ./bin/scripts/prefs/basic.sh "$installBasicIdleDelay" "$installBasicTerminalName" &>/dev/null

    endLoading "$loading"
  ) &
  runLoading "$loading"
fi

if [ "$installKeybind" = "true" ] ; then
  loading=$(startLoading "Configuring Keybinds")
  (
    bash ./bin/scripts/prefs/keybind.sh &>/dev/null

    endLoading "$loading"
  ) &
  runLoading "$loading"
fi

if [ "$installTaskbar" = "true" ] ; then
  loading=$(startLoading "Configuring Taskbar")
  (
    bash ./bin/scripts/prefs/taskbar.sh "$installTaskbarIntellihide" &>/dev/null
    endLoading "$loading"
  ) &
  runLoading "$loading"
fi

if [ "$installGuake" = "true" ] ; then
  loading=$(startLoading "Configuring Guake Terminal")
  (
    bash ./bin/scripts/prefs/guake.sh "$installGuakeKeybind" &>/dev/null

    endLoading "$loading"
  ) &
  runLoading "$loading"
fi
