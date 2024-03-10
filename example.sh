#!/bin/bash


#
# SET the TUI to whiptail 
#
[[ -x "$(command -v whiptail)" ]] && DIALOG="whiptail" || { echo "Try; sudo apt install whiptail" && exit 1 ; }

[[ $1 == "dev" ]] && [[ "${EUID:-$(id -u)}" != 0 ]] && dynamic_poc="true"
[[ $1 == "kb" ]] && desktop_keyboard


dynamic_poc="true"


#
# So called runtime checks dynamic meni item
#
something="Hello World"
testing="$(date +"%B %d, %Y")"
system="$(see_current_apt)"
network="$(see_ping)"
localisation="$LANG"
install="$(see_current_apt)"


# Append Items to menu descriptions 
json_data=$(echo "$json_data" | jq --arg str "$testing" '(.menu[] | select(.id == "Testing"   ) .description) += " (" + $str + ")"')
#json_data=$(echo "$json_data" | jq --arg str "$system" '(.menu[] | select(.id == "System"   ) .description) += " (" + $str + ")"')  
#json_data=$(echo "$json_data" | jq --arg str "$network" '(.menu[] | select(.id == "Network"   ) .description) += " (" + $str + ")"')
json_data=$(echo "$json_data" | jq --arg str "$localisation" '(.menu[] | select(.id == "Localisation"   ) .description) += " (" + $str + ")"')
#json_data=$(echo "$json_data" | jq --arg str "$install" '(.menu[] | select(.id == "Install"   ) .description) += " (" + $str + ")"')

#
# Append Items to Sub menu descriptions 
json_data=$(echo "$json_data" | jq --arg str "$network" '(.menu[] | select(.id=="Testing").sub[] | select(.id == "T2").description) += " (" + $str + ")"')
json_data=$(echo "$json_data" | jq --arg str "$install" '(.menu[] | select(.id=="Testing").sub[] | select(.id == "T1").description) += " (" + $str + ")"')
json_data=$(echo "$json_data" | jq --arg str "$install" '(.menu[] | select(.id=="Install").sub[] | select(.id == "I0").description) += " (" + $str + ")"')


#Show or hide main menu items dynamicly
json_data=$(echo "$json_data" | jq '(.menu[] | select(.id=="System" ) .show) |= true')
json_data=$(echo "$json_data" | jq '(.menu[] | select(.id=="Network") .show) |= true')     
json_data=$(echo "$json_data" | jq '(.menu[] | select(.id=="Install") .show) |= true') 

# Hide tesing from user/admin settings
[[ "$1" != "dev" ]] && json_data=$(echo "$json_data" | jq '(.menu[] | select(.id=="Testing") .show) |= false') ;

[[ $EUID != 0 ]] && json_data=$(echo "$json_data" | jq '(.menu[] | select(.id=="System") .show) |= false') ;
[[ $EUID != 0 ]] && json_data=$(echo "$json_data" | jq '(.menu[] | select(.id=="Localisation") .show) |= false') ;
[[ $EUID != 0 ]] && json_data=$(echo "$json_data" | jq '(.menu[] | select(.id=="Install") .show) |= false') ;
[[ $EUID != 0 ]] && json_data=$(echo "$json_data" | jq '(.menu[] | select(.id=="Network") .show) |= false') ;

# Hide Personalisation from Global settings
[[ $EUID == 0 ]] && json_data=$(echo "$json_data" | jq '(.menu[] | select(.id=="Personalisation") .show) |= false') ;

#
#Show or hide Sub menu items dynamicly
#json_data=$(echo "$json_data" | jq '(.menu[] | select(.id=="System").sub[] | select(.id == "S1").show) |= true')
#json_data=$(echo "$json_data" | jq '(.menu[] | select(.id=="Help").sub[] | select(.id == "H1").show) |= false')


