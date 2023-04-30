#!/bin/bash

package_manager="$1"

if [ -z "$package_manager" ] ; then
  exit
fi

mkdir tmp-download-themes
cd tmp-download-themes

git clone -n --depth=1 --filter=tree:0 https://github.com/AspieSoft/SpecialModificationsForLinux.git
cd SpecialModificationsForLinux

git sparse-checkout set --no-cone "/bin/themes/"

mv bin/themes ../../bin

cd ../..
rm -rf tmp-download-themes
