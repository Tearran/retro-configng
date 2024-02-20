# Start of apt.dependencies.sh
#!/bin/bash


#
# Define the options for this module
#
declare -A module_options=( 
    ["get_dependencies,long"]="get_deps=\"\""
    ["get_dependencies,disc"]="Install missing dependencies"
    ["get_dependencies,use"]="  get_dependencies \"arg1 arg2 arg3...\""

    ["remove_dependencies,long"]="rm-deps"
    ["remove_dependencies,disc"]="Remove installed dependencies"
    ["remove_dependencies,use"]="  remove_dependencies \"arg1 arg2 arg3...\"" 

    ["get_current_apt,long"]="see-apt"
    ["get_current_apt,disc"]="Check if apt, apt-get, or dpkg is currently running, and package list is up-to-date"
    ["get_current_apt,use"]="  see_current_apt"
)

#
# Merge the module options into the global options
#
for key in "${!module_options[@]}"; do
    options["$key"]="${module_options[$key]}"
done


#
# Function to check if apt, apt-get, or dpkg is currently running, and package list is up-to-date
#
see_current_apt() {
    # Number of seconds in a day
    local day=86400

    # Get the current date as a Unix timestamp
    local now=$(date +%s)

    # Get the timestamp of the most recently updated file in /var/lib/apt/lists/
    local update=$(stat -c %Y /var/lib/apt/lists/* | sort -n | tail -1)

    # Calculate the number of seconds since the last update
    local elapsed=$(( now - update ))

    if ps -C apt-get,apt,dpkg >/dev/null; then
        echo "apt-get, apt, or dpkg is currently running."
        return 1  # The processes are running
    else
        echo "Continuing, apt, apt-get, or dpkg is not currently running"
    fi
    # Check if the package list is up-to-date
    if (( elapsed < day )); then
        echo "Checking for apt-daily.service"
        echo "The package lists were last updated $(date -u -d @${elapsed} +"%T") ago."
        return 0  # The package lists are up-to-date
    else
        echo "Checking for apt-daily.service"
        echo "The package lists are not up-to-date."
        return 1  # The package lists are not up-to-date
    fi
}


#
# Function to install missing dependencies
#
function get_dependencies() {
    see_current_apt || return 1
    for dep in "$@"; do
        echo "Checking for dependency: $dep"
        if ! command -v $dep &> /dev/null; then
            echo "$dep could not be found, attempting to install..."
            apt-get install -y $dep
            if [ $? -ne 0 ]; then
                echo "Failed to install $dep. Please install it manually."
                return 1
            fi
        fi
        echo "$dep is installed."
    done
#    echo "All dependencies are installed."
   return 0
}


#
# Function to remove installed dependencies
#
function remove_dependencies() {
    see_current_apt || return 1
    for dep in "$@"; do
        echo "Checking for dependency: $dep"
        if command -v $dep &> /dev/null; then
            echo "$dep found, attempting to remove..."
            apt-get purge -y $dep
            if [ $? -ne 0 ]; then
                echo "Failed to remove $dep. Please remove it manually."
                return 1
            fi
        else
            echo "$dep is not installed."
        fi
    done
    #echo "All specified dependencies are removed."
    return 0
}

#
# Function to update the package lists (WIP)
#
update_packages() {
    echo "Updating package lists..."
    apt-get update
    return 0
}
# End of apt.dependencies.sh
# Start of apt.firmware.sh
#!/bin/bash

#
# Define the options for this module
#
declare -A module_options=(
    ["see_firmware_hold,long"]="see-firmware"
    ["see_firmware_hold,disc"]="Check if firmware, kernel, and u-boot are held back from upgrades"
    ["see_firmware_hold,use"]="  see_firmware_hold"
    
    ["hold_packages,long"]="freeze-firmware"
    ["hold_packages,disc"]="Hold back firmware, kernel, and u-boot from upgrades"
    ["hold_packages,use"]="  hold_packages"

    ["unhold_packages,long"]="unfreeze-firmware"
    ["unhold_packages,disc"]="Unhold firmware, kernel, and u-boot from upgrades"
    ["unhold_packages,use"]="  unhold_packages"
)


#
# Merge the module options into the global options
#
for key in "${!module_options[@]}"; do
    options["$key"]="${module_options[$key]}"
done


#
# check the hold status of the packages
#
function see_firmware_hold() {
    source /etc/armbian-release
    packages=("linux-image-current-$LINUXFAMILY" "linux-u-boot-$BOARD-$BRANCH" "u-boot-tools ")

    for package in "${packages[@]}"; do
        dpkg --get-selections | grep "$package" | grep "hold"
        if [ $? -eq 0 ]; then
            echo " $package is held back from upgrades."
            export firmware_update="unhold"
        else
            echo " $package is not held back from upgrades."
            export firmware_update="hold"
        fi
    done
}


#
# Function to hold back firmware, kernel, and u-boot from upgrades
#
function hold_packages() {
    source /etc/armbian-release
    packages=("linux-image-current-$LINUXFAMILY" "linux-u-boot-$BOARD-$BRANCH" "u-boot-tools")

    for package in "${packages[@]}"; do
        sudo apt-mark hold "$package"
    done
}


#
# Function to unhold firmware, kernel, and u-boot from upgrades
#
function unhold_packages() {
    source /etc/armbian-release
    packages=("linux-image-current-$LINUXFAMILY" "linux-u-boot-$BOARD-$BRANCH" "u-boot-tools")

    for package in "${packages[@]}"; do
        sudo apt-mark unhold "$package"
    done
}


# 
# Function to check the hold status of the packages
#
function check_hold_status() {
    source /etc/armbian-release
    packages=("linux-image-current-$LINUXFAMILY" "linux-u-boot-$BOARD-$BRANCH" "u-boot-tools")

    for package in "${packages[@]}"; do
        dpkg --get-selections | grep "$package" | grep "hold"
        if [ $? -eq 0 ]; then
            echo "$package is held back from upgrades."
            export firmware_update="unhold"
        else
            echo "$package is not held back from upgrades."
            export firmware_update="hold"
        fi
    done
}


#
# Function to toggle the hold status of the packages
#
function toggle_hold_status() {
    source /etc/armbian-release
    packages=("linux-image-current-$LINUXFAMILY" "linux-u-boot-$BOARD-$BRANCH" "u-boot-tools")

    for package in "${packages[@]}"; do
        if [[ $firmware_update == "unhold" ]]; then
            sudo apt-mark unhold "$package"
        else
            sudo apt-mark hold "$package"
        fi
    done
}
# End of apt.firmware.sh
# Start of dev.config.editor.sh
#!/bin/bash


#
# Declare the module options
#
declare -A module_options=( 
    ["serve_debug"]="--serve-debug"
    ["serve_debug,disc"]="Serve the debug server"
    ["serve_debug,use"]="  serve_debug"
)


#
# Merge the module options into the global options
#
for key in "${!module_options[@]}"; do
    options["$key"]="${module_options[$key]}"
done


#
# Function to serve the edit and debug server
#
function serve_debug() {
    if [[ "$(id -u)" == "0" ]] ; then
        echo "Red alert! not for sude user"
        exit 1
    fi
    if [[ -z $CODESPACES ]]; then
        # Start the Python server in the background
        python3 -m http.server > /tmp/config.log 2>&1 &
        local server_pid=$!	
        local input=("
 Starting server...
        Server PID: $server_pid
        
    Press [Enter] to exit"
            )

        [[ $DIALOG != "bash" ]] && $DIALOG --title "Message Box" --msgbox "$input" 0 0
        [[ $DIALOG == "bash" ]] && echo -e "$input"
        [[ $DIALOG == "bash" ]] && read -p -r "Press [Enter] to continue..." ; echo "" ; exit 1

        # Stop the server
        kill $server_pid
        return 0
    else
        echo "Info:GitHub Codespace"
        exit 0
    fi
}


#
# build a monolithic file from the module files
#
consolidate_files() {
    local modpath="$1"
    local output_file="$2"

    for file in "$modpath"/*.sh
    do
        if [[ -f "$file" ]]; then
            # Add a start marker
            echo "# Start of $(basename "$file")" >> "$output_file"
            
            # Add the contents of the file
            cat "$file" >> "$output_file"
            
            # Add an end marker
            echo "# End of $(basename "$file")" >> "$output_file"
        fi
    done
} 

 consolidate_files "$libpath/config.its" "$libpath/config.its.sh" 



#
# split the monolithic file to module files
#
split_files() {
    local input_file="$1"
    local output_dir="$2"
    local current_file=""

    while IFS= read -r line
    do
        if [[ "$line" == "# Start of "* ]]; then
            # Extract the file name from the start marker
            current_file="$output_dir/$(basename "${line#*of }")"
            # Initialize the file
            > "$current_file"
        elif [[ "$line" == "# End of "* ]]; then
            # Clear the current file when we reach the end marker
            current_file=""
        elif [[ -n "$current_file" ]]; then
            # If we're inside a file (between start and end markers), append the line to the file
            echo "$line" >> "$current_file"
        fi
    done < "$input_file"
}
# mkdir -p "$libpath/config.its/"
# split_files "$libpath/config.its.sh" "$libpath/config.its"


# End of dev.config.editor.sh
# Start of dialogue.box.sh
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
# End of dialogue.box.sh
# Start of ping.network.sh
#!/bin/bash

#
# Declare the module options
#
declare -A module_options=( 
	["see_ping,long"]="see-ping"
    ["see_ping,disc"]="Check connection with fallback DNS"
    ["see_ping,use"]="  see_ping"
)


#
# Merge the module options into the global options
#
for key in "${!module_options[@]}"; do
    options["$key"]="${module_options[$key]}"
done


#
# Function to check connection with fallback DNS
#
function see_ping() {
	# List of servers to ping
	servers=("1.1.1.1" "8.8.8.8")

	# Check for internet connection
	for server in "${servers[@]}"; do
	    if ping -q -c 1 -W 1 $server >/dev/null; then
	        echo "Internet connection is present."
			break
	    else
	        echo "Internet connection: Failed"
			sleep 1
	    fi
	done

	if [[ $? -ne 0 ]]; then
		read -n 1 -s -p "Warning: Configuration cannot work properly without a working internet connection. \
		Press CTRL C to stop or any key to ignore and continue."
	fi
}
# End of ping.network.sh
# Start of see.array.menu.sh
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
# End of see.array.menu.sh
# Start of see.data.menu.sh
#!/bin/bash


#
# Declare the module options
#
declare -A module_options=( 
    ["set_colors,long"]="set-colors=\"0\""
    ["set_colors,disc"]="set the colors"
    ["set_colors,use"]="  set_colors (number 0-1)"
)


#
# Merge the module options into the global options
#
for key in "${!module_options[@]}"; do
    options["$key"]="${module_options[$key]}"
done


#
# Function to check connection with fallback DNS
# 
function set_colors() {
    local color_code=$1

    if [ "$dialog_cmd" = "whiptail" ]; then
        set_newt_colors "$color_code"
         #echo "color code: $color_code" | show_infobox ;
    elif [ "$dialog_cmd" = "dialog" ]; then
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
    color_option="green"
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
                menu_options+=("$id" "$description")
            fi
        else
            # If the condition field is empty or null, add the menu item to the menu
            menu_options+=("$id" "$description")
        fi
    done < <(jq -r '.menu[] | select(.show==true) | "\(.id)\n\(.description)\n\(.condition)"' "$json_file")

    set_colors 4

    local OPTION=$($dialog_cmd --title "Menu" --menu "Choose an option" 0 80 9 "${menu_options[@]}" 3>&1 1>&2 2>&3)
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


#
# Function to execute the command
#
function execute_command() {
    local id=$1
    local commands=$(jq -r --arg id "$id" '.menu[] | .. | objects | select(.id==$id) | .command[]' "$json_file")
    for command in "${commands[@]}"; do
        eval "$command"
    done
}
# End of see.data.menu.sh
# Start of apt.dependencies.sh
#!/bin/bash


#
# Define the options for this module
#
declare -A module_options=( 
    ["get_dependencies,long"]="get_deps=\"\""
    ["get_dependencies,disc"]="Install missing dependencies"
    ["get_dependencies,use"]="  get_dependencies \"arg1 arg2 arg3...\""

    ["remove_dependencies,long"]="rm-deps"
    ["remove_dependencies,disc"]="Remove installed dependencies"
    ["remove_dependencies,use"]="  remove_dependencies \"arg1 arg2 arg3...\"" 

    ["get_current_apt,long"]="see-apt"
    ["get_current_apt,disc"]="Check if apt, apt-get, or dpkg is currently running, and package list is up-to-date"
    ["get_current_apt,use"]="  see_current_apt"
)

#
# Merge the module options into the global options
#
for key in "${!module_options[@]}"; do
    options["$key"]="${module_options[$key]}"
done


#
# Function to check if apt, apt-get, or dpkg is currently running, and package list is up-to-date
#
see_current_apt() {
    # Number of seconds in a day
    local day=86400

    # Get the current date as a Unix timestamp
    local now=$(date +%s)

    # Get the timestamp of the most recently updated file in /var/lib/apt/lists/
    local update=$(stat -c %Y /var/lib/apt/lists/* | sort -n | tail -1)

    # Calculate the number of seconds since the last update
    local elapsed=$(( now - update ))

    if ps -C apt-get,apt,dpkg >/dev/null; then
        echo "apt-get, apt, or dpkg is currently running."
        return 1  # The processes are running
    else
        echo "Continuing, apt, apt-get, or dpkg is not currently running"
    fi
    # Check if the package list is up-to-date
    if (( elapsed < day )); then
        echo "Checking for apt-daily.service"
        echo "The package lists were last updated $(date -u -d @${elapsed} +"%T") ago."
        return 0  # The package lists are up-to-date
    else
        echo "Checking for apt-daily.service"
        echo "The package lists are not up-to-date."
        return 1  # The package lists are not up-to-date
    fi
}


#
# Function to install missing dependencies
#
function get_dependencies() {
    see_current_apt || return 1
    for dep in "$@"; do
        echo "Checking for dependency: $dep"
        if ! command -v $dep &> /dev/null; then
            echo "$dep could not be found, attempting to install..."
            apt-get install -y $dep
            if [ $? -ne 0 ]; then
                echo "Failed to install $dep. Please install it manually."
                return 1
            fi
        fi
        echo "$dep is installed."
    done
#    echo "All dependencies are installed."
   return 0
}


#
# Function to remove installed dependencies
#
function remove_dependencies() {
    see_current_apt || return 1
    for dep in "$@"; do
        echo "Checking for dependency: $dep"
        if command -v $dep &> /dev/null; then
            echo "$dep found, attempting to remove..."
            apt-get purge -y $dep
            if [ $? -ne 0 ]; then
                echo "Failed to remove $dep. Please remove it manually."
                return 1
            fi
        else
            echo "$dep is not installed."
        fi
    done
    #echo "All specified dependencies are removed."
    return 0
}

#
# Function to update the package lists (WIP)
#
update_packages() {
    echo "Updating package lists..."
    apt-get update
    return 0
}
# End of apt.dependencies.sh
# Start of apt.firmware.sh
#!/bin/bash

#
# Define the options for this module
#
declare -A module_options=(
    ["see_firmware_hold,long"]="see-firmware"
    ["see_firmware_hold,disc"]="Check if firmware, kernel, and u-boot are held back from upgrades"
    ["see_firmware_hold,use"]="  see_firmware_hold"
    
    ["hold_packages,long"]="freeze-firmware"
    ["hold_packages,disc"]="Hold back firmware, kernel, and u-boot from upgrades"
    ["hold_packages,use"]="  hold_packages"

    ["unhold_packages,long"]="unfreeze-firmware"
    ["unhold_packages,disc"]="Unhold firmware, kernel, and u-boot from upgrades"
    ["unhold_packages,use"]="  unhold_packages"
)


#
# Merge the module options into the global options
#
for key in "${!module_options[@]}"; do
    options["$key"]="${module_options[$key]}"
done


#
# check the hold status of the packages
#
function see_firmware_hold() {
    source /etc/armbian-release
    packages=("linux-image-current-$LINUXFAMILY" "linux-u-boot-$BOARD-$BRANCH" "u-boot-tools ")

    for package in "${packages[@]}"; do
        dpkg --get-selections | grep "$package" | grep "hold"
        if [ $? -eq 0 ]; then
            echo " $package is held back from upgrades."
            export firmware_update="unhold"
        else
            echo " $package is not held back from upgrades."
            export firmware_update="hold"
        fi
    done
}


#
# Function to hold back firmware, kernel, and u-boot from upgrades
#
function hold_packages() {
    source /etc/armbian-release
    packages=("linux-image-current-$LINUXFAMILY" "linux-u-boot-$BOARD-$BRANCH" "u-boot-tools")

    for package in "${packages[@]}"; do
        sudo apt-mark hold "$package"
    done
}


#
# Function to unhold firmware, kernel, and u-boot from upgrades
#
function unhold_packages() {
    source /etc/armbian-release
    packages=("linux-image-current-$LINUXFAMILY" "linux-u-boot-$BOARD-$BRANCH" "u-boot-tools")

    for package in "${packages[@]}"; do
        sudo apt-mark unhold "$package"
    done
}


# 
# Function to check the hold status of the packages
#
function check_hold_status() {
    source /etc/armbian-release
    packages=("linux-image-current-$LINUXFAMILY" "linux-u-boot-$BOARD-$BRANCH" "u-boot-tools")

    for package in "${packages[@]}"; do
        dpkg --get-selections | grep "$package" | grep "hold"
        if [ $? -eq 0 ]; then
            echo "$package is held back from upgrades."
            export firmware_update="unhold"
        else
            echo "$package is not held back from upgrades."
            export firmware_update="hold"
        fi
    done
}


#
# Function to toggle the hold status of the packages
#
function toggle_hold_status() {
    source /etc/armbian-release
    packages=("linux-image-current-$LINUXFAMILY" "linux-u-boot-$BOARD-$BRANCH" "u-boot-tools")

    for package in "${packages[@]}"; do
        if [[ $firmware_update == "unhold" ]]; then
            sudo apt-mark unhold "$package"
        else
            sudo apt-mark hold "$package"
        fi
    done
}
# End of apt.firmware.sh
# Start of dev.config.editor.sh
#!/bin/bash


#
# Declare the module options
#
declare -A module_options=( 
    ["serve_debug"]="--serve-debug"
    ["serve_debug,disc"]="Serve the debug server"
    ["serve_debug,use"]="  serve_debug"
)


#
# Merge the module options into the global options
#
for key in "${!module_options[@]}"; do
    options["$key"]="${module_options[$key]}"
done


#
# Function to serve the edit and debug server
#
function serve_debug() {
    if [[ "$(id -u)" == "0" ]] ; then
        echo "Red alert! not for sude user"
        exit 1
    fi
    if [[ -z $CODESPACES ]]; then
        # Start the Python server in the background
        python3 -m http.server > /tmp/config.log 2>&1 &
        local server_pid=$!	
        local input=("
 Starting server...
        Server PID: $server_pid
        
    Press [Enter] to exit"
            )

        [[ $DIALOG != "bash" ]] && $DIALOG --title "Message Box" --msgbox "$input" 0 0
        [[ $DIALOG == "bash" ]] && echo -e "$input"
        [[ $DIALOG == "bash" ]] && read -p -r "Press [Enter] to continue..." ; echo "" ; exit 1

        # Stop the server
        kill $server_pid
        return 0
    else
        echo "Info:GitHub Codespace"
        exit 0
    fi
}


#
# build a monolithic file from the module files
#
consolidate_files() {
    local modpath="$1"
    local output_file="$2"

    for file in "$modpath"/*.sh
    do
        if [[ -f "$file" ]]; then
            # Add a start marker
            echo "# Start of $(basename "$file")" >> "$output_file"
            
            # Add the contents of the file
            cat "$file" >> "$output_file"
            
            # Add an end marker
            echo "# End of $(basename "$file")" >> "$output_file"
        fi
    done
} 

 consolidate_files "$libpath/config.its" "$libpath/config.its.sh" 



#
# split the monolithic file to module files
#
split_files() {
    local input_file="$1"
    local output_dir="$2"
    local current_file=""

    while IFS= read -r line
    do
        if [[ "$line" == "# Start of "* ]]; then
            # Extract the file name from the start marker
            current_file="$output_dir/$(basename "${line#*of }")"
            # Initialize the file
            > "$current_file"
        elif [[ "$line" == "# End of "* ]]; then
            # Clear the current file when we reach the end marker
            current_file=""
        elif [[ -n "$current_file" ]]; then
            # If we're inside a file (between start and end markers), append the line to the file
            echo "$line" >> "$current_file"
        fi
    done < "$input_file"
}
# mkdir -p "$libpath/config.its/"
# split_files "$libpath/config.its.sh" "$libpath/config.its"


# End of dev.config.editor.sh
# Start of dialogue.box.sh
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
# End of dialogue.box.sh
# Start of ping.network.sh
#!/bin/bash

#
# Declare the module options
#
declare -A module_options=( 
	["see_ping,long"]="see-ping"
    ["see_ping,disc"]="Check connection with fallback DNS"
    ["see_ping,use"]="  see_ping"
)


#
# Merge the module options into the global options
#
for key in "${!module_options[@]}"; do
    options["$key"]="${module_options[$key]}"
done


#
# Function to check connection with fallback DNS
#
function see_ping() {
	# List of servers to ping
	servers=("1.1.1.1" "8.8.8.8")

	# Check for internet connection
	for server in "${servers[@]}"; do
	    if ping -q -c 1 -W 1 $server >/dev/null; then
	        echo "Internet connection is present."
			break
	    else
	        echo "Internet connection: Failed"
			sleep 1
	    fi
	done

	if [[ $? -ne 0 ]]; then
		read -n 1 -s -p "Warning: Configuration cannot work properly without a working internet connection. \
		Press CTRL C to stop or any key to ignore and continue."
	fi
}
# End of ping.network.sh
# Start of see.array.menu.sh
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
# End of see.array.menu.sh
# Start of see.data.menu.sh
#!/bin/bash


#
# Declare the module options
#
declare -A module_options=( 
    ["set_colors,long"]="set-colors=\"0\""
    ["set_colors,disc"]="set the colors"
    ["set_colors,use"]="  set_colors (number 0-1)"
)


#
# Merge the module options into the global options
#
for key in "${!module_options[@]}"; do
    options["$key"]="${module_options[$key]}"
done


#
# Function to check connection with fallback DNS
# 
function set_colors() {
    local color_code=$1

    if [ "$dialog_cmd" = "whiptail" ]; then
        set_newt_colors "$color_code"
         #echo "color code: $color_code" | show_infobox ;
    elif [ "$dialog_cmd" = "dialog" ]; then
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
    color_option="green"
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
                menu_options+=("$id" "$description")
            fi
        else
            # If the condition field is empty or null, add the menu item to the menu
            menu_options+=("$id" "$description")
        fi
    done < <(jq -r '.menu[] | select(.show==true) | "\(.id)\n\(.description)\n\(.condition)"' "$json_file")

    set_colors 4

    local OPTION=$($dialog_cmd --title "Menu" --menu "Choose an option" 0 80 9 "${menu_options[@]}" 3>&1 1>&2 2>&3)
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


#
# Function to execute the command
#
function execute_command() {
    local id=$1
    local commands=$(jq -r --arg id "$id" '.menu[] | .. | objects | select(.id==$id) | .command[]' "$json_file")
    for command in "${commands[@]}"; do
        eval "$command"
    done
}
# End of see.data.menu.sh
