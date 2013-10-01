gos-install
===========

Installer for /g/OS, currently in the form of a simple buildscript. Boot a Gentoo livecd, connect to the internet and run

#### Usage ####
Run the script with the device block you have partitioned to be the root, like so:
```sh
./build.sh sda1
```
Different architectures can be selected by changing the value of ARCH in build.sh
