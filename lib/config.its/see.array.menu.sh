#!/bin/bash


#
# Declare the module options
#
declare -A module_options=( 
    ["parse_json,long"]="parse-json"
    ["parse_json,disc"]="Parse Data for debug and testing"
    ["parse_json,use"]="  parse_json"
)


#
# Merge the module options into the global options
#
for key in "${!module_options[@]}"; do
    options["$key"]="${module_options[$key]}"
done


#
# Function to parse the JSON data
#
function parse_json() {
    # Read the JSON file into a variable
    json=$(cat $directory/etc/armbian-config/retro-config.json)

    # Get the length of the 'menu' array
    length=$(echo "$json" | jq '.menu | length')

    # Iterate over each element in the 'menu' array
    for ((i=0; i<$length; i++)); do
        # Extract the 'id' and 'description' of the current menu
        id=$(echo "$json" | jq -r ".menu[$i].id")
        description=$(echo "$json" | jq -r ".menu[$i].description")

        echo "Menu ID: $id"
        echo "Menu Description: $description"

        # Get the length of the 'sub' array of the current menu
        sub_length=$(echo "$json" | jq ".menu[$i].sub | length")

        # Iterate over each element in the 'sub' array
        for ((j=0; j<$sub_length; j++)); do
            # Extract the 'id', 'description', 'command', 'show', 'network', and 'requirements' of the current submenu
            sub_id=$(echo "$json" | jq -r ".menu[$i].sub[$j].id")
            sub_description=$(echo "$json" | jq -r ".menu[$i].sub[$j].description")
            sub_command=$(echo "$json" | jq -r ".menu[$i].sub[$j].command")
            sub_show=$(echo "$json" | jq -r ".menu[$i].sub[$j].show")
            sub_network=$(echo "$json" | jq -r ".menu[$i].sub[$j].network")
            sub_requirements=$(echo "$json" | jq -r ".menu[$i].sub[$j].requirements[]")

            echo "  Submenu ID: $sub_id"
            echo "  Submenu Description: $sub_description"
            echo "  Submenu Command: $sub_command"
            echo "  Submenu Show: $sub_show"
            echo "  Submenu Network: $sub_network"
            echo "  Submenu Requirements: $sub_requirements"
            echo
        done
    done
}
