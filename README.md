# PhoenixInstaller
Install PhoenixOS in your linux system without needing for Windows.
# Disclaimer
This script is still under testing.. so you may face a problem while installing or may have system boot issue if something went wrong.. so please report any problems to make it more stable and reliable.
## This has been tested on
**Ubuntu LTS**

**LinuxMint**

**LinuxLite**
# Installation Steps
1- Download latest Phoenix iso file from their official website [Here](http://www.phoenixos.com/en/download_x86)

2 - Make sure that your linux partition have at least **35GB** space.
2- Place the script in the same path of the .iso file.

3- Start the script and proceed to the installation.
```bash
chmod 750 phoenix-installer.sh
./phoenix-installer.sh
```
4- Enter **1** to Install the PhoenixOs, it will take some time depends on your machine, just **Don't Interrupt it** to avoid any critical issues.
# Uninstallation Steps
1- Start the script and Enter **2** to start uninstallation process, it will remove PhoenixOs from your system and from grub menu either.
