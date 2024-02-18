#!/bin/bash

# Declare the module options
declare -A module_options=( 
    ["author"]="Joey Turner"

    ["set_newt_colors"]="--set-newt-colors"
    ["set_newt_colors,disc"]="Set the color of the newt interface"
    ["set_newt_colors,use"]="  set_newt_colors \"arg1\""

    ["serve_debug"]="--serve-debug"
    ["serve_debug,disc"]="Serve the debug server"
    ["serve_debug,use"]="  serve_debug"

)

# Merge the module options into the global options
for key in "${!module_options[@]}"; do
    options["$key"]="${module_options[$key]}"
done

set_newt_colors() {
    local color_code="$1"
    case $color_code in
        0) color="green" ;; # passing
        1) color="red" ;;   # failing
        2) color="yellow" ;; # warning
        3) color="black" ;; # normal
        4) color="blue" ;; # info
        5) color="magenta" ;; # error
        6) color="cyan" ;; # success
        7) color="white" ;; # default
        *) echo "$1 is a Invalid color code"; return 1 ;;
    esac
    export NEWT_COLORS="root=,$color"
}
# Serve array editor
serve_debug() {
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

