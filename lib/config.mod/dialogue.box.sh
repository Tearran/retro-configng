#!/bin/bash


# Check if whiptail is installed

[[ -x "$(command -v dialog)" ]] && export DIALOG="dialog"
[[ -x "$(command -v whiptail)" ]] && export DIALOG="whiptail"
# Define the options for this module
declare -A module_options=( 
    ["author"]="Joey Turner"
    ["show_menu,long"]="--see-menu"
    ["show_menu,disc"]="Show a TUI menu and get the user's choice"
    ["show_message,long"]="--message"
    ["show_message,disc"]="Display a OK message box"
    ["show_infobox,long"]="--infobox"
    ["show_infobox,disc"]="Display a infobox with a message"
    ["show_yesno,long"]="--coninue"
    ["show_yesno,disc"]="Display a Yes/No message box"
)

# Merge the module options into the global options
for key in "${!module_options[@]}"; do
    options["$key"]="${module_options[$key]}"
done

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

show_message00(){

    # Read the input from the pipe continuously until there is no more input
    input=""
    while read -r line; do
        input+="$line\n"
    done

    # Display the "OK" message box with the input data
    [[ $DIALOG != "bash" ]] && $DIALOG --title "Message Box" --msgbox "$input" 0 0

    }

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

show_yesno() {
    # Check if there's any input from the pipe
    if [ -p /dev/stdin ]; then
        # Read the input from the pipe
        input=$(cat)
    else
        # If there's no input, set a default message
        input="Do you want to continue?"
    fi

    # Display the Yes/No dialog box with the input data
    if [[ $DIALOG != "bash" ]]; then
        if $DIALOG --title "Yes/No Dialog" --yesno "$input" 0 0; then
            return 0  # User selected Yes
        else
            exit 1  # User selected No or closed the dialog
        fi
    else
        echo "$input"
        echo "No dialog program available. Please run this script in an environment with 'dialog' or 'whiptail'."
        exit 1
    fi
}
