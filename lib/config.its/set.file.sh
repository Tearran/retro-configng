#!/bin/bash



#
# Define the options for this module
#
module_options+=(
["edit_file,feature"]="edit_file"
["edit_file,desc"]="Edit a file with an avaliblet editor"
["edit_file,example"]="\"pth/to/file\""

["consolidate_files,feature"]="consolidate_files"
["consolidate_files,desc"]="build a monolithic file from the module files"
["consolidate_files,example"]="consolidate_files \"path/to/folder\" \"path/to/file.sh\""

["split_files,feature"]="split_files"
["split_files,desc"]="split the monolithic file to module files"
["split_files,example"]="split_files \"path/to/file.sh\" \"path/to/folder\""
)


#
# Function to edit a file
#
function edit_file() {
    # Array of preferred editors
    local editors=("nano" "vi" "vim" "emacs")

    # Use the first argument as the file to be edited
    local file="$1"

    # Check if a file was provided
    if [ -z "$file" ]; then
        echo "No file provided. Usage: edit_file <file>"
        return 1
    fi

    # Find the first available editor
    local editor=""
    for potential_editor in "${editors[@]}"; do
        if command -v $potential_editor >/dev/null 2>&1; then
            editor=$potential_editor
            break
        fi
    done

    # Check if an editor was found
    if [ -z "$editor" ]; then
        echo "No suitable editor found."
        return 1
    fi

    # Open the file with the editor
    sudo $editor "$file"
}


#
# build a monolithic file from the module files
#
consolidate_files_alpha() {
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
#consolidate_files "$libpath/config.its" "$libpath/config.its.sh" 

consolidate_files() {
    local modpath="$1"
    local output_file="$2"

    # Add a shebang to the first line of the output file
    echo "#!/bin/bash" > "$output_file"

    for file in "$modpath"/*.sh
    do
        if [[ -f "$file" ]]; then
            # Add a start marker
            echo "# Start of $(basename "$file")" >> "$output_file"
            
            # Remove the shebang from the file and add the contents to the output file
            sed '/^#!\/bin\/bash/d' "$file" >> "$output_file"
            
            # Add an end marker
            echo "# End of $(basename "$file")" >> "$output_file"

            # Add a newline
            echo "" >> "$output_file"
        fi
    done
}


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

#mkdir -p "$libpath/config.split"
#split_files "$libpath/config.its.sh" "$libpath/config.split" ; exit 1


    for key in "${!module_options[@]}"; do
        options["$key"]="${module_options[$key]}"
    done


    for key in "${!module_options[@]}"; do
        options["$key"]="${module_options[$key]}"
    done

