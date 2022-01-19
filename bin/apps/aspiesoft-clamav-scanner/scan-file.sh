#!/bin/bash

DIR="$1"
FILE="$2"
scanList="$3"

isScanning="false"
while read line ; do
  if [ "$line" = "$FILE" ] ; then
    isScanning="true"
    break
  fi
done < $scanList

if [ "$isScanning" = "true" ] ; then
  exit
fi

echo "$FILE" >> $scanList

(
  fileName=$(echo $FILE | sed -e "s#^$DIR/##")

  notify-send -i "/etc/aspiesoft-clamav-scanner/icon.png" -t 3 "Started Scanning" "$fileName"

  clamscan -r --bell --move="/VirusScan/quarantine" --exclude-dir="/VirusScan/quarantine" $FILE &>/dev/null
  sed "#^$FILE$#d" $scanList

  if [ -s "$FILE" ] ; then

    if [ -f "$FILE" ] || [ -d "$FILE" ] ; then
      notify-send -i "/etc/aspiesoft-clamav-scanner/icon-green.png" -t 3 "File Is Safe" "$fileName"
    else
      notify-send -i "/etc/aspiesoft-clamav-scanner/icon-red.png" -t 3 "Warning: File Moved To Quarantine" "$fileName"
    fi

    # notify-send -i "/etc/aspiesoft-clamav-scanner/icon.png" -t 3 "Finished Scanning $fileName"
  fi
) &
