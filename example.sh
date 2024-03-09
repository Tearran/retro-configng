#!/bin/bash


script_dir="$(dirname "$0")/"
json_file="$script_dir/procedure.json"
json_data=$(cat "$json_file")


#
# SET the TUI to whiptail 
#
[[ -x "$(command -v whiptail)" ]] && export DIALOG="whiptail"


#
# Show Admin Menu
#
[[ "${EUID:-$(id -u)}" -eq 0 ]] && echo "test"  && dynamic_poc="false"


#
# Show Dev Menu
[[ $1 == "dev" ]] && [[ "${EUID:-$(id -u)}" != 0 ]] && dynamic_poc="true"


#
# Load the library Dynamic menu entries and feature list
#
declare -A module_options

source "$script_dir"config.its.sh

for key in "${!module_options[@]}"; do
    options["$key"]="${module_options[$key]}"
done


#
# So called runtime checks dynamic meni item
#
export something=$(see_ping)

#
# Check if the application is in development mode
#
if [ "$dynamic_poc" == "true" ]; then

    # Append menu descriptions 
    json_data=$(echo "$json_data" | jq --arg str "$something" '(.menu[] | select(.id == "Run Time"   ) .description) += " (" + $str + ")"')
    json_data=$(echo "$json_data" | jq --arg str "$something" '(.menu[] | select(.id == "Network"   ) .description) += " (" + $str + ")"')

    json_data=$(echo "$json_data" | jq --arg str "New message" '(.menu[] | select(.id=="Run Time").sub[] | select(.id == "T1").description) += " (" + $str + ")"')
    json_data=$(echo "$json_data" | jq --arg str "$LANG" '(.menu[] | select(.id == "Localisation"   ) .description) += " (" + $str + ")"')  
    #Show or hide main menbu dynamicly
    json_data=$(echo "$json_data" | jq '(.menu[] | select(.id=="Run Time") .show) |= true')
    json_data=$(echo "$json_data" | jq '(.menu[] | select(.id=="Network") .show) |= true')
    #Show or hide Sub menu dynamicly
    json_data=$(echo "$json_data" | jq '(.menu[] | select(.id=="System").sub[] | select(.id == "S1").show) |= false')
    #json_data=$(echo "$json_data" | jq '(.menu[] | select(.id=="Run Time").sub[] | select(.id == "T0").show) |= false')
fi


#
# Update the Readme Document
[[ $1 == "-r" ]] && generate_readme && exit 0


#
# Generate the top menu with the modified JSON data
while generate_top_menu "$json_data"; do :; done;


exit 0 ; 
