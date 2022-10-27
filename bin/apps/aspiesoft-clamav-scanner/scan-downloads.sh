#!/bin/bash

DIR="$1"
SCAN_LIMIT="$2"

scanList=$(mktemp) && echo "" > $scanList

function cleanup {
  trap - SIGHUP SIGINT SIGTERM SIGQUIT
  rm "$pidfile" > /dev/null 2>&1;
  rm -r "$workpath" > /dev/null 2>&1;
  rm $scanList
  kill -- -$$
  exit 0
}
trap cleanup EXIT


scanCount=0


# inotifywait -q -m -r -e close_write,move,delete_self --format '%w%f' "$DIR" | while read FILE ; do
inotifywait -q -m -r -e close_write --format '%w%f' "$DIR" | while read FILE ; do
  # if ! [ -d "$DIR" ] ; then
  #   exit
  # fi

  if [ -s "$FILE" ] ; then
    (
      sleep 1
      if [ -s "$FILE" ] && ! [[ "$FILE" =~ .*\.crdownload$ ]] && ! [[ "$FILE" =~ .*\.part$ ]] ; then
        while [ $scanCount -ge $SCAN_LIMIT ] ; do
          sleep 1
        done

        scanCount=$((scanCount+1))
        bash /etc/aspiesoft-clamav-scanner/scan-file.sh "$DIR" "$FILE" "$scanList"
        scanCount=$((scanCount-1))
      fi
    ) &
  fi
done
