#!/bin/bash


#
# Define the options for this module
#

# Declare module_options as an associative array


module_options+=(
["serve_doc,feature"]="serve_doc"
["serve_doc,desc"]="Start the Doc server to tst output files"
["serve_doc,example"]="serve_doc"

["join_scripts,feature"]="join_scripts"
["join_scripts,desc"]="Join the script modules into one file"
["join_scripts,example"]="join_scripts"

["split_script,feature"]="split_script"
["split_script,desc"]="Split the script into multiple Module files"
["split_script,example"]="split_script"

)

#
# Function to serve the edit and debug server
#
function serve_doc() {
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

        $DIALOG --title "Message Box" --msgbox "$input" 0 0

        # Stop the server
        kill "$server_pid"
    else
        echo "Info:GitHub Codespace"
        exit 0
    fi
}


#
# Function to Join the script modules into one file
#
join_scripts() {
    local modpath="$1"
    local output_file="$2"

    # Add a shebang and the declaration of the module_options associative array to the first lines of the output file
    echo -e "#!/bin/bash\n\tdeclare -A module_options" > "$output_file"

    for file in "$modpath"/*.sh
    do
        if [[ -f "$file" ]]; then
            # Add a marker
            echo "# Start of $(basename "$file")" >> "$output_file"

            # Remove the shebang from the file and add the contents to the output file
            sed '/^#!\/bin\/bash/d' "$file" >> "$output_file"
            
            # Add a newline
            echo "" >> "$output_file"
        fi
    done

    #echo "    for key in \"\${!module_options[@]}\"; do" >> "$output_file"
    #echo "        options[\"\$key\"]=\"\${module_options[\$key]}\"" >> "$output_file"
    #echo "    done" >> "$output_file"
}


#
# Function to split the script into multiple Module files
#
split_script() {
    local input_file="$1"
    local output_dir="$2"
    mkdir -p "$output_dir"

    awk '
        BEGIN { RS = "\n# Start of"; FS = "\n"; OFS = "\n"; ORS = "\n"; }
        NR > 1 {
            sub(/ /, "", $1);
            output_file = sprintf("%s/%s", "'"$output_dir"'", $1);
            $1 = "#!/bin/bash";
            print $0 > output_file;
        }
    ' "$input_file"
}
