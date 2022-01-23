#!/bin/bash

MouseSpeed=8


keyDetectDir=$(mktemp -d)
echo "0" | tee "$keyDetectDir/close" &>/dev/null
echo "0" | tee "$keyDetectDir/caps" &>/dev/null
echo "0" | tee "$keyDetectDir/up" &>/dev/null
echo "0" | tee "$keyDetectDir/down" &>/dev/null
echo "0" | tee "$keyDetectDir/left" &>/dev/null
echo "0" | tee "$keyDetectDir/right" &>/dev/null


function cleanup() {
  echo "1" | tee "$keyDetectDir/close" &>/dev/null
}
trap cleanup EXIT


#todo: dasable default mouse movement on caps lock pressed


(
  xinput test-xi2 --root 3 | gawk '/RawKeyPress/ {getline; getline; print $2; fflush()}' | while read -r key; do
    if [[ $(cat "$keyDetectDir/close") == "1" ]]; then
      echo "2" | tee "$keyDetectDir/close" &>/dev/null
      exit
    elif [[ $(cat "$keyDetectDir/close") == "2" ]]; then
      rm -rf "$keyDetectDir"
      unset keyDetectDir
      exit
    fi

    if [[ $(cat "$keyDetectDir/caps") == "1" ]]; then
      if [[ "$key" == "111" && $(cat "$keyDetectDir/down") -le 1 ]]; then # Up
        if [[ $(cat "$keyDetectDir/up") == "-1" ]]; then
          echo "0" | tee "$keyDetectDir/up" &>/dev/null
        else
          echo "2" | tee "$keyDetectDir/up" &>/dev/null
          xdotool keyup Up
          echo "-1" | tee "$keyDetectDir/down" &>/dev/null
          xdotool key Down
        fi
      elif [[ "$key" == "116" && $(cat "$keyDetectDir/up") -le 1 ]]; then # Down
        if [[ $(cat "$keyDetectDir/down") == "-1" ]]; then
          echo "0" | tee "$keyDetectDir/down" &>/dev/null
        else
          echo "2" | tee "$keyDetectDir/down" &>/dev/null
          xdotool keyup Down
          echo "-1" | tee "$keyDetectDir/up" &>/dev/null
          xdotool key Up
        fi
      elif [[ "$key" == "113" && $(cat "$keyDetectDir/right") -le 1 ]]; then # Left
        if [[ $(cat "$keyDetectDir/left") == "-1" ]]; then
          echo "0" | tee "$keyDetectDir/left" &>/dev/null
        else
          echo "2" | tee "$keyDetectDir/left" &>/dev/null
          xdotool keyup Left
          echo "-1" | tee "$keyDetectDir/right" &>/dev/null
          xdotool key Right
        fi
      elif [[ "$key" == "114" && $(cat "$keyDetectDir/left") -le 1 ]]; then # Right
        if [[ $(cat "$keyDetectDir/right") == "-1" ]]; then
          echo "0" | tee "$keyDetectDir/right" &>/dev/null
        else
          echo "2" | tee "$keyDetectDir/right" &>/dev/null
          xdotool keyup Right
          echo "-1" | tee "$keyDetectDir/left" &>/dev/null
          xdotool key Left
        fi
      elif [[ "$key" == "62" ]]; then # R_Shift
        xdotool keyup Shift
        xdotool click 1
      elif [[ "$key" == "61" ]]; then # Slash
        xdotool click 3
      fi
    fi
  done
) &

(
  xinput test-xi2 --root 3 | gawk '/RawKeyRelease/ {getline; getline; print $2; fflush()}' | while read -r key; do
    if [[ $(cat "$keyDetectDir/close") == "1" ]]; then
      echo "2" | tee "$keyDetectDir/close" &>/dev/null
      exit
    elif [[ $(cat "$keyDetectDir/close") == "2" ]]; then
      rm -rf "$keyDetectDir"
      unset keyDetectDir
      exit
    fi

    if [[ $(cat "$keyDetectDir/caps") == "1" ]]; then
      if [[ "$key" == "111" ]]; then # Up
        keyUp=$(cat "$keyDetectDir/up")
        if [[ "$keyUp" -ge 1 ]]; then
          echo "$((keyUp-1))" | tee "$keyDetectDir/up" &>/dev/null
        fi
      elif [[ "$key" == "116" ]]; then # Down
        keyDown=$(cat "$keyDetectDir/down")
        if [[ "$keyDown" -ge 1 ]]; then
          echo "$((keyDown-1))" | tee "$keyDetectDir/down" &>/dev/null
        fi
      elif [[ "$key" == "113" ]]; then # Left
        keyLeft=$(cat "$keyDetectDir/left")
        if [[ "$keyLeft" -ge 1 ]]; then
          echo "$((keyLeft-1))" | tee "$keyDetectDir/left" &>/dev/null
        fi
      elif [[ "$key" == "114" ]]; then # Right
        keyRight=$(cat "$keyDetectDir/right")
        if [[ "$keyRight" -ge 1 ]]; then
          echo "$((keyRight-1))" | tee "$keyDetectDir/right" &>/dev/null
        fi
      fi
    fi

    if [[ "$key" == "66" ]]; then # Caps
      capsKey=$(xset q | grep Caps)
      if [[ "$capsKey" =~ ^.*?Caps([\s\t ]*Lock|):([\s\t ]*)(on|true).*$ ]]; then
        echo "1" | tee "$keyDetectDir/caps" &>/dev/null
      else
        echo "0" | tee "$keyDetectDir/caps" &>/dev/null

        echo "0" | tee "$keyDetectDir/up" &>/dev/null
        echo "0" | tee "$keyDetectDir/down" &>/dev/null
        echo "0" | tee "$keyDetectDir/left" &>/dev/null
        echo "0" | tee "$keyDetectDir/right" &>/dev/null

        xdotool keyup Up
        xdotool keyup Down
        xdotool keyup Left
        xdotool keyup Right
      fi
    fi
  done
) &

mouseMoveX=0
mouseMoveY=0
keyCheckLoop=0

while true; do
  if [[ $(cat "$keyDetectDir/caps") == "1" ]]; then

    keyCheckLoop=$((keyCheckLoop+1))

    if [[ keyCheckLoop -ge "3" ]]; then
      keyCheckLoop=0

      keyUp=$(cat "$keyDetectDir/up")
      keyDown=$(cat "$keyDetectDir/down")
      keyLeft=$(cat "$keyDetectDir/left")
      keyRight=$(cat "$keyDetectDir/right")

      mouseMoveX=0
      mouseMoveY=0

      if [[ "$keyUp" -ge "1" && "$keyDown" -le "0" ]]; then
        mouseMoveY="-$MouseSpeed"
      elif [[ "$keyUp" -le "0" && "$keyDown" -ge "1" ]]; then
        mouseMoveY="$MouseSpeed"
      fi

      if [[ "$keyLeft" -ge "1" && "$keyRight" -le "0" ]]; then
        mouseMoveX="-$MouseSpeed"
      elif [[ "$keyLeft" -le "0" && "$keyRight" -ge "1" ]]; then
        mouseMoveX="$MouseSpeed"
      fi
    fi

    xdotool mousemove_relative -- "$mouseMoveX" "$mouseMoveY"

    sleep 0.01

  fi
done
