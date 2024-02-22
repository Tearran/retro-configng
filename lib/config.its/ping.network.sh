#!/bin/bash

#
# Declare the module options
#
module_options+=(
["see_ping,feature"]="see_ping"
["see_ping,desc"]="Check for internet connection"
["see_ping,example"]=""
)


#
# Function to check connection with fallback DNS
#
function see_ping() {
	# List of servers to ping
	servers=("1.1.1.1" "8.8.8.8")

	# Check for internet connection
	for server in "${servers[@]}"; do
	    if ping -q -c 1 -W 1 $server >/dev/null; then
	        echo "Internet connection is present."
			break
	    else
	        echo "Internet connection: Failed"
			sleep 1
	    fi
	done

	if [[ $? -ne 0 ]]; then
		read -n 1 -s -p "Warning: Configuration cannot work properly without a working internet connection. \
		Press CTRL C to stop or any key to ignore and continue."
	fi
}
