# Linux ClamAV Download Scanner

[![donation link](https://img.shields.io/badge/buy%20me%20a%20coffee-paypal-blue)](https://paypal.me/shaynejrtaylor?country.x=US&locale.x=en_US)

> This module is currently in beta.

Automatically scan your linux home directory when you download something new.

By default, this module only scans common directoried (Downloads, Desktop, etc.) and searches for extension directories like your chrome extensions.
I may add additional directories in future updates.
Currently, this module only uses the active users home directories, and does not touch the root directory.

## Installation

```shell script
# add this file to your startup script
./linux-clamav-download-scanner

# optional: add additional directories to watch for downloads
./linux-clamav-download-scanner MyDir1 MyDir2 MyDir...
```
