#!/bin/bash


#
# Define the options for this module
#

# Declare module_options as an associative array


module_options+=( 
    ["serve_debug,feature"]="serve-debug"
    ["serve_debug,desc"]="Start a simple http server"
    ["serve_debug,example"]="serve_debug"
)


#
# Function to serve the edit and debug server
#
function serve_debug() {
    if [[ "$(id -u)" == "0" ]] ; then
        echo "Red alert! not for sude user"
        exit 1
    fi
    if [[ -z $CODESPACES ]]; then
        # Start the Python server in the background
        python3 -m http.server > /tmp/config.log 2>&1 &
        local server_pid=$!	
        local input=("
 Starting server...
        Server PID: $server_pid
        
    Press [Enter] to exit"
            )

        [[ $DIALOG != "bash" ]] && $DIALOG --title "Message Box" --msgbox "$input" 0 0
        [[ $DIALOG == "bash" ]] && echo -e "$input"
        [[ $DIALOG == "bash" ]] && read -p -r "Press [Enter] to continue..." ; echo "" ; exit 1

        # Stop the server
        kill $server_pid
        return 0
    else
        echo "Info:GitHub Codespace"
        exit 0
    fi
}







