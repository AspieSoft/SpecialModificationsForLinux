#!/bin/bash


if ! [[ $(crontab -l) == *"# aspiesoft-clamav-scan"* ]] ; then
  crontab -l | { cat; echo '0 2 * * * sudo clamscan -r --bell --move="/VirusScan/quarantine" --exclude-dir="/VirusScan/quarantine" --exclude-dir="/home/$USER/.clamtk/viruses" --exclude-dir="smb4k" --exclude-dir="/run/user/$USER/gvfs" --exclude-dir="/home/$USER/.gvfs" --exclude-dir=".thunderbird" --exclude-dir=".mozilla-thunderbird" --exclude-dir=".evolution" --exclude-dir="Mail" --exclude-dir="kmail" --exclude-dir="^/sys" / # aspiesoft-clamav-scan'; } | crontab -
fi

/etc/aspiesoft-clamav-scanner/linux-clamav-download-scanner/linux-clamav-download-scanner

#DIR="$PWD"

# cd "$HOME"
# for FILE in * ; do
#  if ! [[ "$FILE" == .* || "$FILE" == "core" || "$FILE" == "snap" ]] ; then
#    if [ -d "$FILE" ] ; then
#      bash /etc/aspiesoft-clamav-scanner/scan-downloads.sh "$HOME/$FILE" 1 &
#    fi
#  fi
# done
# cd "$DIR"

#bash /etc/aspiesoft-clamav-scanner/scan-downloads.sh "$HOME/Downloads" 3 &
# bash /etc/aspiesoft-clamav-scanner/scan-downloads.sh "$HOME/Documents" 1 &
# bash /etc/aspiesoft-clamav-scanner/scan-downloads.sh "$HOME/Pictures" 1 &
# bash /etc/aspiesoft-clamav-scanner/scan-downloads.sh "$HOME/Videos" 1 &
# bash /etc/aspiesoft-clamav-scanner/scan-downloads.sh "$HOME/Desktop" 1 &


# inotifywait -q -m -e create,move --format '%w%f' "$HOME" | while read FILE ; do
#  if ! [[ "$FILE" == .* || "$FILE" == "core" || "$FILE" == "snap" ]] ; then
#    if [ -d "$FILE" ] ; then
#      bash /etc/aspiesoft-clamav-scanner/scan-downloads.sh "$FILE" 1 &
#    fi
#  fi
# done


# cron job

# 0 0 * * * sudo clamscan -r --bell --move="/VirusScan/quarantine" --exclude-dir="/VirusScan/quarantine" --exclude-dir="/home/$USER/.clamtk/viruses" --exclude-dir="smb4k" --exclude-dir="/run/user/$USER/gvfs" --exclude-dir="/home/$USER/.gvfs" --exclude-dir=".thunderbird" --exclude-dir=".mozilla-thunderbird" --exclude-dir=".evolution" --exclude-dir="Mail" --exclude-dir="kmail" --exclude-dir="^/sys" /


# crontab -l | { cat; echo '0 2 * * * sudo clamscan -r --bell --move="/VirusScan/quarantine" --exclude-dir="/VirusScan/quarantine" --exclude-dir="/home/$USER/.clamtk/viruses" --exclude-dir="smb4k" --exclude-dir="/run/user/$USER/gvfs" --exclude-dir="/home/$USER/.gvfs" --exclude-dir=".thunderbird" --exclude-dir=".mozilla-thunderbird" --exclude-dir=".evolution" --exclude-dir="Mail" --exclude-dir="kmail" --exclude-dir="^/sys" / # aspiesoft-clamav-scan'; } | crontab -
