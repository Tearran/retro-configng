#!/bin/bash

# Authors
author+=("(c) 2022 Joey Turner. All rights reserved.")
long_option+=("--serve-debug")
# Help message
readarray -t -O "${#help_message[@]}" help_message <<EOF
lib/config.mod/dev.config.editor.sh

  # Simple server
    debug and edit arrays will exit if the user is root
      serve_debug 

EOF
set_newt_colors() {
    local color_code=$1
    case $color_code in
        0) color="green" ;; # passing
        1) color="red" ;;   # failing
        2) color="yellow" ;; # warning
        3) color="black" ;; # normal
        4) color="blue" ;; # info
        5) color="magenta" ;; # error
        6) color="cyan" ;; # success
        7) color="white" ;; # default
        *) echo "Invalid color code"; return 1 ;;
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

