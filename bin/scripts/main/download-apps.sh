#!/bin/bash

package_manager="$1"

if [ -z "$package_manager" ] ; then
  exit
fi

mkdir tmp-download-apps
cd tmp-download-apps

git clone -n --depth=1 --filter=tree:0 https://github.com/AspieSoft/SpecialModificationsForLinux.git
cd SpecialModificationsForLinux

git sparse-checkout set --no-cone "/bin/apps/"

mv bin/apps ../../bin

cd ../..
rm -rf tmp-download-apps
