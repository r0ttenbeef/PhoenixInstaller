#!/bin/bash
Red='\033[0;31m'
Green='\033[0;32m'
Yellow='\033[0;33m'
Blue='\033[0;34m'
Purple='\033[0;35m'
off='\033[0m'

err="[${Red}-${off}]"
warn="[${Yellow}!${off}]"
prog="[${Blue}*${off}]"
done="[${Green}+${off}]"
ask="[${Purple}?${off}]"

version="1.0 Beta"
author="deadc0w"
sha256hash="ac19baee1611b494898f2f481c3ef480b1705ecb33676b4f3a5af864499e7ce0"
os_path="/phoenix" # DONT CHANGE #

function cprint(){
    echo -e $1
}

function ps(){
    printf ">> "
}

chk_root(){
    if [ $EUID != 0 ];then cprint "$err Cannot use the script without root access!";exit 1;else clear;fi
}

function chk_iso(){
    if [ -f PhoenixOSInstaller*.iso ];then
        cprint "$prog verifing the iso file.."
        if [[ $(sha256sum PhoenixOSInstaller*.iso | grep $sha256hash) ]];then 
            cprint "$done iso file is verified!"
        else
            cprint "$err Cannot verify iso file, make sure that you have download it from phoenix official website"
            exit 8
        fi
    else 
        cprint "$err Please move the iso file in the same path of the script!"; exit 2
    fi
    #pause
}

function installation(){
    if [[ -d $os_path ]] || [[ $(cat /etc/grub.d/40_custom | grep -i phoenixos) ]] ;then cprint "$warn PhoenixOS is already installed";exit 6;fi
    
    files=( "initrd.img" "install.img" "kernel" "ramdisk.img" "system.sfs" )
    
    if [ ! -d $os_path ]; then 
        cprint "$prog Setting directories"
        mkdir $os_path; mkdir $os_path/data/; touch $os_path/data.img
    else
        cprint "$err Phoenix directory already exist in / directory"; exit 3
    fi
    
    cprint "$prog Extracting iso file.."
    7z x -ophinst PhoenixOSInstaller*.iso > /dev/null
    for i in ${files[*]};do
        cprint "$prog moving $i"
        if [ -f phinst/$i ]; then mv phinst/$i $os_path;else cprint "$err Error while moving sys files!";exit 4;fi
    done

    cprint "$prog Creating ROM for the OS (Takes some time).."
    dd if=/dev/zero of=$os_path/data.img bs=1M count=32768 #32GB size for ROM
    mkfs.ext4 $os_path/data.img > /dev/null
    
    cprint "$prog Setting bootable PhoenixOS with grub"
    echo """
menuentry \"PhoenixOS\"{
    insmod part_gpt
    search --file --no-floppy --set=root $os_path/system.sfs
    linux $os_path/kernel root=/dev/ram0 androidboot.hardware=android_x86 SRC=phoenix/
    initrd $os_path/initrd.img
}""" >> /etc/grub.d/40_custom
	sed -i 's/^GRUB_HIDDEN_/#GRUB_HIDDEN_/' /etc/default/grub
    update-grub
	
    if [ $? == 0 ];then cleanup;exit 0; else cprint "$err Errors while updating grub!"; cleanup; exit 5;fi
}

function uninstallation(){
    if [[ ! -d $os_path ]]; then cprint "$warn PhoenixOS is not installed!";exit 7;fi
    cprint "$warn Removing PhoenixOS files.."
    #shred -zun3 $os_path/* 2> /dev/null
    rm -rf $os_path

    cprint "$warn Removing dualboot configurations"
    sed -i '/menuentry \"PhoenixOS\"/,+5d' /etc/grub.d/40_custom
    update-grub

    cprint "$done PhoenixOS Uninstalled Successfully"; exit 0
}

function cleanup(){
    cprint "$warn cleaning up.."
    #shred -zun3 phinst/* 2> /dev/null
    rm -rf phinst
    cprint "$done Exiting"
}

function menu_page(){
    echo -e """
${Blue}   ___ _                      _        ___  __ ${Green}   _____           _        _ _           
${Blue}  / _ \\ |__   ___   ___ _ __ (_)_  __ /___\\/ _\\\\${Green}   \\_   \\_ __  ___| |_ __ _| | | ___ _ __ 
${Blue} / /_)/ '_ \\ / _ \\ / _ \\ '_ \\| \\ \\/ ///  //\\ \\\\${Green}     / /\\/ '_ \\/ __| __/ _\` | | |/ _ \\ '__|
${Blue}/ ___/| | | | (_) |  __/ | | | |>  </ \\_// _\\ \\ /\\\\${Green}/ /_ | | | \\__ \ || (_| | | |  __/ |   
${Blue}\/    |_| |_|\\___/ \\___|_| |_|_/_/\\_\\___/  \\__/ ${Green}\\____/ |_| |_|___/\\__\\__,_|_|_|\\___|_|

                                ${off}Author: ${Yellow}$author ${off}Version: ${Yellow}$version
           ${Red}WARNING! THIS MAY MAKE YOUR SYSTEM UNBOOTABLE .. USE IT AT YOUR OWN RISK${off}

$ask Choose between these options:
[${Blue}1${off}] Install PhoenixOS
[${Red}2${off}] Uninstall PhoenixOS
[${Yellow}q${off}] Exit
"""
}

chk_root
menu_page
while true;do
    ps
    read options
    case $options in
        1) chk_iso;installation;;
        2) uninstallation;;
        "exit"|"q"|"quit") exit 0;;
        *) cprint "$err choose the option number to perform!";menu_page;;
    esac
done
