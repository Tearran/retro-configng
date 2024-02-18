#!/bin/bash

# Declare the module options
declare -A module_options=( 
    ["co_authors"]="Tearran"
    ["set_colors,long"]="--set-colors"
    ["set_colors,disc"]="Check connection with fallback DNS"
    ["set_colors,use"]="  set_colors"
)

# Merge the module options into the global options
for key in "${!module_options[@]}"; do
    options["$key"]="${module_options[$key]}"
done

############################
# colors
############################    
set_colors() {
    local color_code=$1

    if [ "$dialog_cmd" = "whiptail" ]; then
        set_newt_colors "$color_code"
    elif [ "$dialog_cmd" = "dialog" ]; then
        set_term_colors "$color_code"
    else
        echo "Invalid dialog type"
        return 1
    fi
}

set_newt_colors() {
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
        *) echo "Invalid color code"; return 1 ;;
    esac
    export NEWT_COLORS="root=,$color"
}

set_term_colors() {
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

reset_colors() {
    echo -e "\e[0m"
}

#############################
trap reset_colors EXIT
#############################

# generate the top-level menu
generate_top_menu() {
    
    #json=$(cat $directory/etc/armbian-config/retro-config.json)
    #clear
    # Get the top-level menu options
    color_option="green"
    local menu_options=()
    while IFS= read -r id
    do
        IFS= read -r description
        menu_options+=("$id" "$description")
    done < <(jq -r '.menu[] | "\(.id)\n\(.description)"' "$json_file")

    set_colors 4 # "$?"

    # Generate the $dialog_cmd menu
    local OPTION=$($dialog_cmd --title "Menu" --menu "Choose an option" 0 80 9 "${menu_options[@]}" 3>&1 1>&2 2>&3)
    local exitstatus=$?

    if [ $exitstatus = 0 ]; then
        if [ "$OPTION" == "" ]; then
            exit 0
        fi    
        generate_menu "$OPTION"
    fi
}

generate_menu() {
    local parent_id=$1

    # Get the submenu options for the current parent_id
    local submenu_options=()
    while IFS= read -r id
    do
        IFS= read -r description
        submenu_options+=("$id" "$description")
    done < <(jq -r --arg parent_id "$parent_id" '.menu[] | .. | objects | select(.id==$parent_id) | .sub[]? | select(.show==true) | "\(.id)\n\(.description)"' "$json_file")
    set_colors 2 # "$?"

    local OPTION=$($dialog_cmd --title "Menu" --menu "Choose an option" 0 80 9 "${submenu_options[@]}" \
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

execute_command() {
    local id=$1
    local requirements=$(jq -r --arg id "$id" '.menu[] | .. | objects | select(.id==$id) | .requirements[]?' "$json_file")
    if get_dependencies "$requirements"; then
        local command=$(jq -r --arg id "$id" '.menu[] | .. | objects | select(.id==$id) | .command' "$json_file")
        eval "$command"
    else
        echo "Failed to meet requirements for command $id"
    fi
}