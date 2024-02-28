#!/bin/bash


#
#
# Define the options for this module
#
module_options+=(
["get_input,feature"]="get_input"
["get_input,desc"]="TODO"
["get_input,example"]="get_input"

["show_menu,feature"]="show_menu"
["show_menu,desc"]="Check for internet connection"
["show_menu,example"]="show_menu"

["show_message,feature"]="show_message"
["show_message,desc"]="Check for internet connection"
["show_message,example"]="pipe output | show_message "

["show_infobox,feature"]="show_infobox"
["show_infobox,desc"]="Show info box"
["show_infobox,example"]=" TODO"

["set_user_input,feature"]="set_user_input"
["set_user_input,desc"]="Display a input dialog use with get_user_input"
["set_user_input,example"]="TODO set_user_input | get_input"

["get_user_input,feature"]="get_user_input"
["get_user_input,desc"]="Display set_user_input results"
["get_user_input,example"]="TODO set_user_input | get_user_input"

["get_user_continue,feature"]="get_user_continue"
["get_user_continue,desc"]="Display a Yes/No dialog box (WIP)"
["get_user_continue,example"]="TODO"

["process_input,feature"]="process_input"
["process_input,desc"]="TODO:Desc"
["process_input,example"]="TODO"
)


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
function show_menu(){
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
function show_message() {
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
function show_infobox() {
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

            TERM=ansi $DIALOG --title "$BACKTITLE" --infobox "$(printf "%s\n" "${buffer[@]}" )" 18 90
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
function set_user_input() {
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
function get_user_input() {
    local input=$($DIALOG --inputbox "Please enter your input: " 10 60 3>&1 1>&2 2>&3)

    if [ $? = 0 ]; then
        $1 "$input"
    else
        echo "You cancelled."
    fi
}




#
# Function to display a Yes/No dialog box (WIP)
#
function get_user_continue() {
    local message="$1"
    local next_action=$2

    if $($DIALOG --yesno "$message" 10 60 3>&1 1>&2 2>&3); then
        $next_action
    else
        $next_action "No"
    fi
}



#
# Function to process the user's input
#
# Function to process the user's choice
function process_input() {
    local input="$1"
    if [ "$input" = "No" ]; then
        exit 1
    else
        echo "You entered: $input"
   fi
}





