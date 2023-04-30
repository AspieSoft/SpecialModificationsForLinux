# Special Modifications for Linux

[![donation link](https://img.shields.io/badge/buy%20me%20a%20coffee-paypal-blue)](https://paypal.me/shaynejrtaylor?country.x=US&locale.x=en_US)

Whether Your new to linux, or just distro hopping, this bash script can make the setup process a bit easier.

This script will set up your distro form enabling the firewall, to adding performance upgrades you would generally find on YouTube. It also fixes a variety of potential issues, and will make sure you have some common apps installed such as gparted.

This bash script is built and tested with ubuntu. I have recently been experimenting with fedora support. The script will automatically detect if you have the apt package manager, or the dnf package manager, and will choose the appropriate installation scripts for that package manager.

Personally, I mostly use ZorinOS, so it may be slightly more optimized for zorin, but should work fine on any ubuntu based distro.

## Whats New

- Added fedora support

## Hou To Use

1. Download and Extract the SpecialModifications.tar.gz

2. Open the folder and double click "install.sh" to install the script for the first time (Click "Run In Terminal" if asked)

3. To run the script again at any time, open a terminal and run "SpecialModifications" or open the folder in your home directory "SpecialModificationsForLinux" and double click "run.sh" to run the script again

4. The first sudo command will ask for your root password, after that, it should stay logged in as root for that session

5. You will see a list of options to choose from, for the initial setup, you can choose "Setup Distro" (the first option)

6. You will be asked some questions about your preferences for the install. You can choose whatever you want, or just press "ENTER" to leave it as the default. (The default option is the capital letter)

7. After you choose your preferences, the install will do its thing. It may take a while, so feel free to sip some coffee.

Note: in step 2 or 3, if "install.sh" or "run.sh" fails to run, right click the file, and go to properties, go to the "permissions" tab, and make sure "allow executing file as program" is checked.
