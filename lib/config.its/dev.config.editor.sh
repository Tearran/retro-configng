#!/bin/bash


#
# Declare the module options
#

module_options+=( 
    ["serve_debug,feature"]="serve-debug"
    ["serve_debug,desc"]="Start a simple http server"
    ["serve_debug,example"]="serve_debug"

    ["consolidate_files,feature"]="consolidate_files"
    ["consolidate_files,desc"]="build a monolithic file from the module files"
    ["consolidate_files,example"]="(WIP)"

    ["split_files,feature"]="split_files"
    ["split_files,desc"]="split the monolithic file to module files"
    ["split_files,example"]="(WIP)"
)

#
# Merge the module options into the global options
#
for key in "${!module_options[@]}"; do
    options["$key"]="${module_options[$key]}"
done

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


#
# build a monolithic file from the module files
#
consolidate_files() {
    local modpath="$1"
    local output_file="$2"

    for file in "$modpath"/*.sh
    do
        if [[ -f "$file" ]]; then
            # Add a start marker
            echo "# Start of $(basename "$file")" >> "$output_file"
            
            # Add the contents of the file
            cat "$file" >> "$output_file"
            
            # Add an end marker
            echo "# End of $(basename "$file")" >> "$output_file"
        fi
    done
} 

# consolidate_files "$libpath/config.its" "$libpath/config.its.sh" 



#
# split the monolithic file to module files
#
split_files() {
    local input_file="$1"
    local output_dir="$2"
    local current_file=""

    while IFS= read -r line
    do
        if [[ "$line" == "# Start of "* ]]; then
            # Extract the file name from the start marker
            current_file="$output_dir/$(basename "${line#*of }")"
            # Initialize the file
            > "$current_file"
        elif [[ "$line" == "# End of "* ]]; then
            # Clear the current file when we reach the end marker
            current_file=""
        elif [[ -n "$current_file" ]]; then
            # If we're inside a file (between start and end markers), append the line to the file
            echo "$line" >> "$current_file"
        fi
    done < "$input_file"
}
# mkdir -p "$libpath/config.its/"
# split_files "$libpath/config.its.sh" "$libpath/config.its"


