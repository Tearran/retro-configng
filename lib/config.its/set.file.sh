#!/bin/bash



#
# Define the options for this module
#
module_options+=(
["edit_file,feature"]="edit_file"
["edit_file,desc"]="Edit a file with an avaliblet editor"
["edit_file,example"]="\"pth/to/file\""

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
# Add the module options to the options array
# This is done last so that the module's functions are not added to the options array
# Join and split may produce multibel of the for loop here. 
#


