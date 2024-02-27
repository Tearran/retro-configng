#!/bin/bash


#
# Define the options for this module
#

module_options+=(
["see_firmware_hold,feature"]="see_firmware_hold"
["see_firmware_hold,desc"]="Check if firmware, kernel, and u-boot are held back from upgrades"
["see_firmware_hold,example"]="TODO:Example"

["unhold_packages,feature"]="unhold_packages"
["unhold_packages,desc"]="Unhold firmware, kernel, and u-boot from upgrades"
["unhold_packages,example"]="TODO:Example"

["hold_packages,feature"]="hold_packages"
["hold_packages,desc"]="Hold firmware, kernel, and u-boot from upgrades"
["hold_packages,example"]="TODO:Example"
)


#
# check the hold status of the packages
#
function see_firmware_hold() {
    source /etc/armbian-release
    packages=("linux-image-current-$LINUXFAMILY" "linux-u-boot-$BOARD-$BRANCH" "u-boot-tools ")

    for package in "${packages[@]}"; do
        dpkg --get-selections | grep "$package" | grep "hold"
        if [ $? -eq 0 ]; then
            echo " $package is held back from upgrades."
            export firmware_update="unhold"
        else
            echo " $package is not held back from upgrades."
            export firmware_update="hold"
        fi
    done
}


#
# Function to hold back firmware, kernel, and u-boot from upgrades
#
function hold_packages() {
    source /etc/armbian-release
    packages=("linux-image-current-$LINUXFAMILY" "linux-u-boot-$BOARD-$BRANCH" "u-boot-tools")

    for package in "${packages[@]}"; do
        sudo apt-mark hold "$package"
    done
}


#
# Function to unhold firmware, kernel, and u-boot from upgrades
#
function unhold_packages() {
    source /etc/armbian-release
    packages=("linux-image-current-$LINUXFAMILY" "linux-u-boot-$BOARD-$BRANCH" "u-boot-tools")

    for package in "${packages[@]}"; do
        sudo apt-mark unhold "$package"
    done
}


# 
# Function to check the hold status of the packages
#
function check_hold_status() {
    source /etc/armbian-release
    packages=("linux-image-current-$LINUXFAMILY" "linux-u-boot-$BOARD-$BRANCH" "u-boot-tools")

    for package in "${packages[@]}"; do
        dpkg --get-selections | grep "$package" | grep "hold"
        if [ $? -eq 0 ]; then
            echo "$package is held back from upgrades."
            export firmware_update="unhold"
        else
            echo "$package is not held back from upgrades."
            export firmware_update="hold"
        fi
    done
}


#
# Function to toggle the hold status of the packages
#
function toggle_hold_status() {
    source /etc/armbian-release
    packages=("linux-image-current-$LINUXFAMILY" "linux-u-boot-$BOARD-$BRANCH" "u-boot-tools")

    for package in "${packages[@]}"; do
        if [[ $firmware_update == "unhold" ]]; then
            sudo apt-mark unhold "$package"
        else
            sudo apt-mark hold "$package"
        fi
    done
}




