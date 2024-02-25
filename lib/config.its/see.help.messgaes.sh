#!/bin/bash



#
# Define the options for this module
#


module_options+=(
["parse_json,feature"]="parse_json"
["parse_json,desc"]="Show readble json"
["parse_json,example"]="parse_json"

["see_use,feature"]="see_use"
["see_use,desc"]="Show in file examples"
["see_use,example"]="see_use"

)

#
# Function to parse the JSON data ouput to markdown, for documentation
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


#
# Function to parse the key-pairs to a JSON file (WIP)
#
function see_use() {
    mod_message="Usage: \n"
    # Iterate over the options
    for key in "${!module_options[@]}"; do
        # Split the key into function_name and type
        IFS=',' read -r function_name type <<< "$key"
        # If the type is 'long', append the option to the help message
        if [[ "$type" == "feature" ]]; then
            mod_message+="  ${module_options["$function_name,desc"]}\n"
            mod_message+="\t${module_options["$function_name,feature"]} ${module_options["$function_name,example"]}\n\n"
        fi
    done

    echo -e "$mod_message"
}
