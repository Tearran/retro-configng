#!/bin/bash



#
# Define the options for this module
#
module_options+=(
["set_colors,feature"]="set_colors"
["set_colors,desc"]="Set a background color"
["set_colors,example"]="(number 0-7)"
    
["reset_colors,feature"]="reset_colors"
["reset_colors,desc"]="Reset the background color"
["reset_colors,example"]="reset_colors"

["generate_top_menu,feature"]="generate_top_menu"
["generate_top_menu,desc"]="Generate the top menu"
["generate_top_menu,example"]="generate_top_menu"

["generate_menu,feature"]="generate_menu"
["generate_menu,desc"]="Generate the submenu"
["generate_menu,example"]="generate_menu"

["execute_command,feature"]="execute_command"
["execute_command,desc"]="Execute a command"
["execute_command,example"]="execute_command"

["generate_restricted_commands","feature"]="generate_restricted_commands"
["generate_restricted_commands","desc"]="List of restricted commands for execute_command"
["generate_restricted_commands","example"]="generate_restricted_commands"
)



#
# Function to check connection with fallback DNS
# 
function set_colors() {
    local color_code=$1

    if [ "$DIALOG" = "whiptail" ]; then
        set_newt_colors "$color_code"
         #echo "color code: $color_code" | show_infobox ;
    elif [ "$DIALOG" = "dialog" ]; then
        set_term_colors "$color_code"
    else
        echo "Invalid dialog type"
        return 1
    fi
}


#
# Function to set the colors for newt
#
function set_newt_colors() {
    local color_code=$1
    case $color_code in
        0) color="black" ;;
        1) color="red" ;;
        2) color="green" ;;
        3) color="yellow" ;;
        4) color="blue" ;;
        5) color="magenta" ;;
        6) color="cyan" ;;
        7) color="white" ;;
        8) color="black" ;;
        9) color="red" ;;
        *) break ;;
    esac
    export NEWT_COLORS="root=,$color"
}


#
# Function to set the colors for terminal
#
function set_term_colors() {
    local color_code=$1
    case $color_code in
        0) color="\e[40m" ;;  # black
        1) color="\e[41m" ;;  # red
        2) color="\e[42m" ;;  # green
        3) color="\e[43m" ;;  # yellow
        4) color="\e[44m" ;;  # blue
        5) color="\e[45m" ;;  # magenta
        6) color="\e[46m" ;;  # cyan
        7) color="\e[47m" ;;  # white
        *) echo "Invalid color code"; return 1 ;;
    esac
    echo -e "$color"
}


#
# Function to reset the colors
#
function reset_colors() {
    echo -e "\e[0m"
}


#
# Trap to reset the colors
#
trap reset_colors EXIT


#
# Function to generate the top menu
#
function generate_top_menu() {
    local menu_options=()
    while IFS= read -r id
    do
        IFS= read -r description
        IFS= read -r condition
        # If the condition field is not empty and not null, run the function specified in the condition
        if [[ -n $condition && $condition != "null" ]]; then
            local condition_result=$(eval $condition)
            # If the function returns a truthy value, add the menu item to the menu
            if [[ $condition_result ]]; then
                menu_options+=("$id" "  -  $description")
            fi
        else
            # If the condition field is empty or null, add the menu item to the menu
            menu_options+=("$id" "  -  $description")
        fi
    done < <(jq -r '.menu[] | select(.show==true) | "\(.id)\n\(.description)\n\(.condition)"' "$json_file"  || exit 1 )

    set_colors 4

    local OPTION=$($DIALOG --title "Menu" --menu "Choose an option" 0 80 9 "${menu_options[@]}" 3>&1 1>&2 2>&3)
    local exitstatus=$?

    if [ $exitstatus = 0 ]; then
        if [ "$OPTION" == "" ]; then
            exit 0
        fi    
        generate_menu "$OPTION"
    fi
}


#
# Function to generate the submenu
#
function generate_menu() {
    local parent_id=$1

    # Get the submenu options for the current parent_id
    local submenu_options=()
    while IFS= read -r id
    do
        IFS= read -r description
        submenu_options+=("$id" "  -  $description")
    done < <(jq -r --arg parent_id "$parent_id" '.menu[] | .. | objects | select(.id==$parent_id) | .sub[]? | select(.show==true) | "\(.id)\n\(.description)"' "$json_file")
    set_colors 2 # "$?"

    local OPTION=$($DIALOG --title "Menu" --menu "Choose an option" 0 80 9 "${submenu_options[@]}" \
                            --ok-button Select --cancel-button Back 3>&1 1>&2 2>&3)

    local exitstatus=$?

    if [ $exitstatus = 0 ]; then
        if [ "$OPTION" == "" ]; then
            generate_top_menu
        fi
        # Check if the selected option has a submenu
        local submenu_count=$(jq -r --arg id "$OPTION" '.menu[] | .. | objects | select(.id==$id) | .sub[]? | length' "$json_file")
        submenu_count=${submenu_count:-0}  # If submenu_count is null or empty, set it to 0
        if [ "$submenu_count" -gt 0 ]; then
            # If it does, generate a new menu for the submenu
            set_colors 2 # "$?"
            generate_menu "$OPTION"
        else
            # If it doesn't, execute the command
            execute_command "$OPTION"
        fi
    fi
}


#
# Function to generate the list of restricted commands
#
function generate_restricted_commands() {
    local restricted_commands=("rm -r" "dd" "fdisk" "mkfs" ":(){ :|:& };:")
    echo "${restricted_commands[@]}"
}


#
# Function to execute the command
#
function execute_command() {
    local id=$1
    local commands=$(jq -r --arg id "$id" '.menu[] | .. | objects | select(.id==$id) | .command[]' "$json_file")

    # Get the list of restricted commands
    local restricted_commands=($(generate_restricted_commands))

    for command in "${commands[@]}"; do
        # Check if the command is not in the list of restricted commands
        if [[ ! " ${restricted_commands[@]} " =~ " ${command} " ]]; then
            eval "$command"
        else
            echo "Command not allowed: $command"
        fi
    done
}




