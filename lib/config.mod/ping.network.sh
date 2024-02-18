#!/bin/bash


# Declare the module options
declare -A module_options=( 
    ["co_authors"]="Joey Turner"
    ["see_ping,long"]="--ping"
    ["see_ping,disc"]="Check connection with fallback DNS"
    ["see_ping,use"]="  see_ping"
)

# Merge the module options into the global options
for key in "${!module_options[@]}"; do
    options["$key"]="${module_options[$key]}"
done

function see_ping() {
    # List of servers to ping
    servers=("1.1.1.1" "8.8.8.8")

    # Check for internet connection
    for server in "${servers[@]}"; do
        if ping -q -c 1 -W 1 "$server" >/dev/null; then
            echo "Internet connection is present."
            return
        else
            echo "Internet connection: Failed, eixting"
			sleep 1
            return 1
        fi
    done
}


