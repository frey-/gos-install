gos-install
===========

Installer for /g/OS, currently in the form of a simple buildscript. Boot a Gentoo livecd, connect to the internet and run.

#### Usage ####
Run the script with the device block you have partitioned to be the root, like so:
```sh
\# ./build.sh sda1
```
Different architectures can be selected by changing the value of ARCH in build.sh. After the initial environment is set up, you'll be required to run another script
```sh
\# ./build_stage2.sh
```
When the package large package emerge starts, you'll be required to answer yes to the 'overwrite?' messages that etc-update displays, so this isn't really something you can set to run overnight.
