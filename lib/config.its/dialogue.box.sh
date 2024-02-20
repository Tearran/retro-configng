#!/bin/bash


#
# Check if whiptail is installed
#
[[ -x "$(command -v dialog)" ]] && export DIALOG="dialog"
[[ -x "$(command -v whiptail)" ]] && export DIALOG="whiptail"


#
# Define the options for this module
#
declare -A module_options=( 
   
    ["show_menu,long"]="--see-menu"
    ["show_menu,disc"]="Show a TUI menu and get the user's choice"
    ["show_menu,use"]="  show_menu"
    
    ["show_message,long"]="--message"
    ["show_message,disc"]="Display a message box"
    ["show_message,use"]="  show_message"
    
    
    ["show_infobox,long"]="--infobox"
    ["show_infobox,disc"]="Display a infobox with a message"
    ["show_infobox,use"]="  show_infobox"
    
    
    ["show_yesno,long"]="--coninue"
    ["show_yesno,disc"]="Display a Yes/No message box"
    ["show_yesno,use"]="  show_yesno"

)

#
# Merge the module options into the global options
#
for key in "${!module_options[@]}"; do
    options["$key"]="${module_options[$key]}"
done


#
# Function to get user input (WIP)
#
function get_input() {
    input=$($DIALOG --inputbox "Please enter your input: " 10 60 3>&1 1>&2 2>&3)
    exitstatus=$?
    if [ $exitstatus = 0 ]; then
        $1 "$input"
    else
        echo "You cancelled."
    fi
}


#
# Function to display a menu and get the user's choice
#
show_menu(){
    # Get the input and convert it into an array of options
    inpu_raw=$(cat)
    # Remove the lines befor -h
	input=$(echo "$inpu_raw" | sed 's/-\([a-zA-Z]\)/\1/' | grep '^  [a-zA-Z] ' | grep -v '\[')
    options=()
    while read -r line; do
        package=$(echo "$line" | awk '{print $1}')
        description=$(echo "$line" | awk '{$1=""; print $0}' | sed 's/^ *//')
        options+=("$package" "$description")
    done <<< "$input"

    # Display the menu and get the user's choice
    [[ $DIALOG != "bash" ]] && choice=$($DIALOG --title "Menu" --menu "Choose an option:" 0 0 9 "${options[@]}" 3>&1 1>&2 2>&3)

	# Check if the user made a choice
	if [ $? -eq 0 ]; then
	    echo "$choice"
	else
	    echo "You cancelled."
	fi
	}


#
# Function to display a message box
#
show_message() {
    # Read the input from the pipe
    input=$(cat)

    # Display the "OK" message box with the input data
    if [[ $DIALOG != "bash" ]]; then
        $DIALOG --title "Message Box" --msgbox "$input" 0 0
    else
        echo -e "$input"
        read -p "Press [Enter] to continue..."
    fi
}


#
# Function to display an infobox with a message
#
show_infobox() {
    export TERM=ansi
    local input
    local BACKTITLE="Processing"
    local -a buffer  # Declare buffer as an array
    if [ -p /dev/stdin ]; then
        while IFS= read -r line; do
            buffer+=("$line")  # Add the line to the buffer
            # If the buffer has more than 10 lines, remove the oldest line
            if (( ${#buffer[@]} > 10 )); then
                buffer=("${buffer[@]:1}")
            fi
            # Display the lines in the buffer in the infobox

            TERM=ansi $DIALOG --title "$BACKTITLE" --infobox "$(printf "%s\n" "${buffer[@]}" )" 16 80
            sleep 0.5
        done
    else
        
        input="$1"
        TERM=ansi $DIALOG --title "$BACKTITLE" --infobox "$( echo "$input" )" 8 80
    fi
        echo -ne '\033[3J' # clear the screen
}


#
# Function to get user input (WIP)
#
set_user_input() {
    # Get the file path from the function argument
    local file="$1"

    # Use whiptail to get user input
    local user_input=$($DIALOG --inputbox "Enter your text" 8 78 --title "Input Box" 3>&1 1>&2 2>&3)

    # Check if the user didn't cancel the input box
    if [ $? = 0 ]; then
        # Save the user input to the file
        echo "$user_input" > "$file"
    else
        echo "User cancelled."
    fi

}
# usage:
# get_user_input "$directory/test.txt"
# [[ -f "$directory/test.txt" ]] && cat "$directory/test.txt" | show_message


#
# Function to get user input (WIP)
#
get_user_input() {
    local input=$($DIALOG --inputbox "Please enter your input: " 10 60 3>&1 1>&2 2>&3)

    if [ $? = 0 ]; then
        $1 "$input"
    else
        echo "You cancelled."
    fi
}
# usage:
# get_user_input "Please enter your input: " process_input "Please enter your input: "



#
# Function to display a Yes/No dialog box (WIP)
#
get_user_continue() {
    local message="$1"
    local next_action=$2

    if $($DIALOG --yesno "$message" 10 60 3>&1 1>&2 2>&3); then
        $next_action
    else
        $next_action "No"
    fi
}

# Usage
#get_user_continue process_input


#
# Function to process the user's input
#
# Function to process the user's choice
process_input() {
    local input="$1"
    if [ "$input" = "No" ]; then
        exit 1
    else
        echo "You entered: $input"
   fi
}
