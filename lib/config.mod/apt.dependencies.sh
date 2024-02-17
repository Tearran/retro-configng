#!/bin/bash


# Declare the module options
declare -A module_options=( 
    ["author"]="Joey Turner"
    ["get_dependencies,long"]="--get_deps"
    ["get_dependencies,disc"]="Install missing dependencies"
    ["get_dependencies,use"]="get_dependencies arg1 arg2 arg3..."
    ["remove_dependencies,long"]="--rm_deps"
    ["remove_dependencies,disc"]="Remove installed dependencies"
    ["remove_dependencies,use"]="remove_dependencies arg1 arg2 arg3..."   
    ["get_current_apt,long"]="--see_apt"
    ["get_current_apt,disc"]="Check if apt, apt-get, or dpkg is currently running, and package list is up-to-date"
    ["get_current_apt,use"]="see_current_apt"
)

# Merge the module options into the global options
for key in "${!module_options[@]}"; do
    options["$key"]="${module_options[$key]}"
done

function see_current_apt() {
    # Number of seconds in a day
    local day=86400

    # Get the current date as a Unix timestamp
    local now=$(date +%s)

    # Get the last start time of apt-daily.service as a Unix timestamp
    local update=$(date -d "$(systemctl show -p ActiveEnterTimestamp apt-daily.service | cut -d'=' -f2)" +%s)

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
        echo "The package lists were last updated $(date -d@$update -u +%H:%M:%S) ago."
        return 0  # The package lists are up-to-date
    else
        echo "Checking for apt-daily.service"
        echo "The package lists are not up-to-date."
        return 1  # The package lists are not up-to-date
    fi
}

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
    echo "All dependencies are installed."
    return 0
}
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
    echo "All specified dependencies are removed."
    return 0
}