#!/bin/bash

# Define the options for this module
declare -A module_options=(
    ["see_firmware_hold,long"]="see-firmware"
    ["see_firmware_hold,disc"]="Check if firmware, kernel, and u-boot are held back from upgrades"
    ["see_firmware_hold,use"]="  see_firmware_hold"
    
    ["hold_packages,long"]="freeze-firmware"
    ["hold_packages,disc"]="Hold back firmware, kernel, and u-boot from upgrades"
    ["hold_packages,use"]="  hold_packages"

    ["unhold_packages,long"]="unfreeze-firmware"
    ["unhold_packages,disc"]="Unhold firmware, kernel, and u-boot from upgrades"
    ["unhold_packages,use"]="  unhold_packages"
)

# Merge the module options into the global options
for key in "${!module_options[@]}"; do
    options["$key"]="${module_options[$key]}"
done


see_firmware_hold() {
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

hold_packages() {
    source /etc/armbian-release
    packages=("linux-image-current-$LINUXFAMILY" "linux-u-boot-$BOARD-$BRANCH" "u-boot-tools")

    for package in "${packages[@]}"; do
        sudo apt-mark hold "$package"
    done
}

unhold_packages() {
    source /etc/armbian-release
    packages=("linux-image-current-$LINUXFAMILY" "linux-u-boot-$BOARD-$BRANCH" "u-boot-tools")

    for package in "${packages[@]}"; do
        sudo apt-mark unhold "$package"
    done
}

#############################
# new 
# Function to check the hold status of the packages
check_hold_status() {
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

# Function to toggle the hold status of the packages
toggle_hold_status() {
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
