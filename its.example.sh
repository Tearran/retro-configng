#!/bin/bash


#
# SET the TUI to whiptail 
#
[[ -x "$(command -v whiptail)" ]] && export DIALOG="whiptail"
#
# Show developemnt playground proof of consepts
[[ $1 == "dev" ]] && [[ "${EUID:-$(id -u)}" != 0 ]] && dynamic_poc="true"
[[ "${EUID:-$(id -u)}" -eq 0 ]] && echo "test"  && dynamic_poc="false"


script_dir="$(dirname "$0")/"
json_file="$script_dir/procedure.json"
json_data=$(cat "$json_file")

#
# This function is used to generate a nested array of arrays that represents the menu structure
#
declare -A module_options

source "$script_dir"config.its.sh

for key in "${!module_options[@]}"; do
    options["$key"]="${module_options[$key]}"
done

export something=$(see_ping)
json_data=$(echo "$json_data" | jq --arg str "$something" '(.menu[] | select(.id == "Run Time"   ) .description) += " (" + $str + ")"')
json_data=$(echo "$json_data" | jq --arg str "$something" '(.menu[]  .sub[] | select(.id == "T0") .description) += " (" + $str + ")"')

# Check if the application is in development mode
if [ "$dynamic_poc" == "true" ]; then
    # If the application is not in development mode, hide the "Run Time" menu item
    json_data=$(echo "$json_data" | jq '(.menu[] | select(.id=="Run Time") .show) |= true')
    json_data=$(echo "$json_data" | jq '(.menu[] | select(.id=="Network") .show) |= false')

fi

# Generate the top menu with the modified JSON data
generate_top_menu "$json_data"
exit 0 ; 
