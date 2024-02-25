#!/bin/bash

#
# Define the options for this module
#
module_options+=( 
["get_dependencies,feature"]="get_dependencies"
["get_dependencies,desc"]="Install missing dependencies"
["get_dependencies,example"]="get_dependencies \"arg1 arg2 arg3...\""

["remove_dependencies,feature"]="rm-deps"
["remove_dependencies,desc"]="Remove installed dependencies"
["remove_dependencies,example"]="remove_dependencies \"arg1 arg2 arg3...\"" 

["get_current_apt,id"]="see-apt"
["get_current_apt,desc"]="Check if apt, apt-get, or dpkg is currently running, and package list is up-to-date"
["get_current_apt,example"]="see_current_apt"

)


#
# Function to check if apt, apt-get, or dpkg is currently running, and package list is up-to-date
#
see_current_apt() {
    # Number of seconds in a day
    local day=86400

    # Get the current date as a Unix timestamp
    local now=$(date +%s)

    # Get the timestamp of the most recently updated file in /var/lib/apt/lists/
    local update=$(stat -c %Y /var/lib/apt/lists/* | sort -n | tail -1)

    # Calculate the number of seconds since the last update
    local elapsed=$(( now - update ))

    if ps -C apt-get,apt,dpkg >/dev/null; then
        echo "apt-get, apt, or dpkg is currently running."
        return 1  # The processes are running
    else
        echo "Continuing, apt, apt-get, or dpkg is not currently running"
    fi
    # Check if the package list is up-to-date
    if (( elapsed < day )); then
        echo "Checking for apt-daily.service"
        echo "The package lists were last updated $(date -u -d @${elapsed} +"%T") ago."
        return 0  # The package lists are up-to-date
    else
        echo "Checking for apt-daily.service"
        echo "The package lists are not up-to-date."
        return 1  # The package lists are not up-to-date
    fi
}


#
# Function to install missing dependencies
#
function get_dependencies() {
    see_current_apt || return 1
    for dep in "$@"; do
        echo "Checking for dependency: $dep"
        if ! command -v $dep &> /dev/null; then
            echo "$dep could not be found, attempting to install..."
            apt-get install -y $dep
            if [ $? -ne 0 ]; then
                echo "Failed to install $dep. Please install it manually."
                return 1
            fi
        fi
        echo "$dep is installed."
    done
#    echo "All dependencies are installed."
   return 0
}


#
# Function to remove installed dependencies
#
function remove_dependencies() {
    see_current_apt || return 1
    for dep in "$@"; do
        echo "Checking for dependency: $dep"
        if command -v $dep &> /dev/null; then
            echo "$dep found, attempting to remove..."
            apt-get purge -y $dep
            if [ $? -ne 0 ]; then
                echo "Failed to remove $dep. Please remove it manually."
                return 1
            fi
        else
            echo "$dep is not installed."
        fi
    done
    #echo "All specified dependencies are removed."
    return 0
}

#
# Function to update the package lists (WIP)
#
update_packages() {
    echo "Updating package lists..."
    apt-get update
    return 0
}

