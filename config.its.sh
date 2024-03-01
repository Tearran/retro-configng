#!/bin/bash
	declare -A module_options
# Start of apt.dependencies.sh

#
# Define the options for this module
#
module_options+=( 
["get_dependencies,feature"]="get_dependencies"
["get_dependencies,desc"]="Install missing dependencies"
["get_dependencies,example"]="get_dependencies \"arg1 arg2 arg3...\""

["remove_dependencies,feature"]="remove_dependencies"
["remove_dependencies,desc"]="Remove installed dependencies"
["remove_dependencies,example"]="remove_dependencies \"arg1 arg2 arg3...\"" 

["get_current_apt,id"]="get_current_apt"
["get_current_apt,desc"]="Check if apt, apt-get, or dpkg is currently running, and package list is up-to-date"
["get_current_apt,example"]="get_current_apt"

)


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




# Start of apt.firmware.sh


#
# Define the options for this module
#

module_options+=(
["see_firmware_hold,feature"]="see_firmware_hold"
["see_firmware_hold,desc"]="Check if firmware, kernel, and u-boot are held back from upgrades"
["see_firmware_hold,example"]="see_firmware_hold"

["unhold_packages,feature"]="unhold_packages"
["unhold_packages,desc"]="Unhold firmware, kernel, and u-boot from upgrades"
["unhold_packages,example"]="unhold_packages"

["hold_packages,feature"]="hold_packages"
["hold_packages,desc"]="Hold firmware, kernel, and u-boot from upgrades"
["hold_packages,example"]="hold_packages"
)


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









# Start of dev.config.sh


#
# Define the options for this module
#

# Declare module_options as an associative array


module_options+=(
["serve_doc,feature"]="serve_doc"
["serve_doc,desc"]="Start the Doc server to tst output files"
["serve_doc,example"]="serve_doc"

["join_scripts,feature"]="join_scripts"
["join_scripts,desc"]="Join the script modules into one file"
["join_scripts,example"]="join_scripts"

["split_script,feature"]="split_script"
["split_script,desc"]="Split the script into multiple Module files"
["split_script,example"]="split_script"

)

#
# Function to serve the edit and debug server
#
function serve_doc() {
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

        $DIALOG --title "Message Box" --msgbox "$input" 0 0

        # Stop the server
        kill "$server_pid"
    else
        echo "Info:GitHub Codespace"
        exit 0
    fi
}


#
# Function to Join the script modules into one file
#
join_scripts() {
    local modpath="$1"
    local output_file="$2"

    # Add a shebang and the declaration of the module_options associative array to the first lines of the output file
    echo -e "#!/bin/bash\n\tdeclare -A module_options" > "$output_file"

    for file in "$modpath"/*.sh
    do
        if [[ -f "$file" ]]; then
            # Add a marker
            echo "# Start of $(basename "$file")" >> "$output_file"

            # Remove the shebang from the file and add the contents to the output file
            sed '/^#!\/bin\/bash/d' "$file" >> "$output_file"
            
            # Add a newline
            echo "" >> "$output_file"
        fi
    done

    #echo "    for key in \"\${!module_options[@]}\"; do" >> "$output_file"
    #echo "        options[\"\$key\"]=\"\${module_options[\$key]}\"" >> "$output_file"
    #echo "    done" >> "$output_file"
}


#
# Function to split the script into multiple Module files
#
split_script() {
    local input_file="$1"
    local output_dir="$2"
    mkdir -p "$output_dir"

    awk '
        BEGIN { RS = "\n# Start of"; FS = "\n"; OFS = "\n"; ORS = "\n"; }
        NR > 1 {
            sub(/ /, "", $1);
            output_file = sprintf("%s/%s", "'"$output_dir"'", $1);
            $1 = "#!/bin/bash";
            print $0 > output_file;
        }
    ' "$input_file"
}




# Start of ping.network.sh


#
# Define the options for this module
#
module_options+=(
["see_ping,feature"]="see_ping"
["see_ping,desc"]="Check for internet connection warn if none"
["see_ping,example"]="see_ping"
)


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









# Start of see.help.messgaes.sh



#
# Define the options for this module
#
module_options+=(
["parse_json,feature"]="parse_json"
["parse_json,desc"]="Show json opjects" 
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
            # Extract the 'id', 'description', 'show', 'network', and 'requirements' of the current submenu
            sub_id=$(echo "$json" | jq -r ".menu[$i].sub[$j].id")
            sub_description=$(echo "$json" | jq -r ".menu[$i].sub[$j].description")
            sub_show=$(echo "$json" | jq -r ".menu[$i].sub[$j].show")
            sub_network=$(echo "$json" | jq -r ".menu[$i].sub[$j].network")
            sub_requirements=$(echo "$json" | jq -r ".menu[$i].sub[$j].requirements[]")

            # Get the length of the 'command' array of the current submenu
            command_length=$(echo "$json" | jq ".menu[$i].sub[$j].command | length")

            # Iterate over each element in the 'command' array
            for ((k=0; k<$command_length; k++)); do
                # Extract the 'command' of the current submenu
                sub_command=$(echo "$json" | jq -r ".menu[$i].sub[$j].command[$k]")
                echo "  Submenu Command: $sub_command"
            done

            echo "  Submenu ID: $sub_id"
            echo "  Submenu Description: $sub_description"
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

function see_use_readme() {
    mod_message="| Feature | Description | Example |\n| --- | --- | --- |\n"
    # Iterate over the options
    for key in "${!module_options[@]}"; do
        # Split the key into function_name and type
        IFS=',' read -r function_name type <<< "$key"
        # If the type is 'feature', append the option to the help message
        if [[ "$type" == "feature" ]]; then
            mod_message+="| ${module_options["$function_name,feature"]} | ${module_options["$function_name,desc"]} | ${module_options["$function_name,example"]} | TODO:|\n"
        fi
    done

    echo -e "$mod_message"
}






# Start of see.json.dialog.sh



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








# Start of see.whiptail.sh


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
    local input=$($DIALOG --inputbox "$task_tile" 10 60 3>&1 1>&2 2>&3)

    if [ $? = 0 ]; then
        $1 "$input"
    else
        echo "You cancelled."
    fi
}



show_menu_alpha(){

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
	    exit 0
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









# Start of set.documents.sh

module_options+=(
["generate_json,feature"]="generate_json"
["generate_json,desc"]="Generate a JSON like format"
["generate_json,example"]="generate_json"

["generate_readme,feature"]="generate_readme"
["generate_readme,desc"]="Generate the README.md file"
["generate_readme,example"]="generate_readme"

)


#
# Function to generate the README.md file
#
generate_readme() {
    echo "Updating README.md."
    # Get the current date
    local current_date=$(date)    

    cat << EOF > "$bin/README.md"
# Experiment: Retro-config
This application is a command-line interface that perform various operations. It is open-source and licensed under the GPL.
 
Updated on $current_date.

# Retro config
## Commanline options 
These options do not work with root privileges and go trough a allow list
~~~

user_commands=(
    ["--help"]="Show this help message"
    ["--readme"]="Update the Features table"
    ["--join"]="Merge the module files into one file"
    ["--split"]="Split the module file into multiple files"
    ["--json"]="Show json like format of the features"
    )

~~~
the following commands are --help message
~~~

$(see_use_help)

~~~

## Example of associtive array 
see *.its.sh in lib/config.its
~~~

module_options+=( 
["feature_name,feature"]="feature_name"
["feature_name,desc"]="A short disc"
["feature_name,example"]="some example"

)

~~~

# FEATURES: Table of Contents
## Table generated by said associtive array
"see_use_readme" function in retro-config script
$(see_use_readme)

# JSON: Object
## Opject generated by said associtive array
"generate_json" function in retro-config script
~~~ 
$(generate_json)

~~~

EOF
    # Print a message indicating that README.md has been updated
    echo "README.md has been updated."

}


#
# ouput a json-like format
#
generate_json() {
features=()
for key in "${!module_options[@]}"; do
    if [[ $key == *",feature" ]]; then
        features+=("${module_options[$key]}")
    fi
done

echo "["
for index in "${!features[@]}"; do
    feature=${features[$index]}
    desc_key="${feature},desc"
    example_key="${feature},example"
    desc="${module_options[$desc_key]}"
    example="${module_options[$example_key]}"
    echo "  {"
    echo "    \"feature\": \"$feature\","
    echo "    \"description\": \"$desc\","
    echo "    \"example\": \"$example\""
    if [ $index -ne $(( ${#features[@]}-1 )) ]; then
        echo "  },"
    else
        echo "  }"
    fi
done
echo "]"
}




# Start of set.file.sh



#
# Define the options for this module
#
module_options+=(
["edit_file,feature"]="edit_file"
["edit_file,desc"]="Edit a file with an avaliblet editor"
["edit_file,example"]="\"pth/to/file\""

)


#
# Function to edit a file
#
function edit_file() {
    # Array of preferred editors
    local editors=("nano" "vi" "vim" "emacs")

    # Use the first argument as the file to be edited
    local file="$1"

    # Check if a file was provided
    if [ -z "$file" ]; then
        echo "No file provided. Usage: edit_file <file>"
        return 1
    fi

    # Find the first available editor
    local editor=""
    for potential_editor in "${editors[@]}"; do
        if command -v $potential_editor >/dev/null 2>&1; then
            editor=$potential_editor
            break
        fi
    done

    # Check if an editor was found
    if [ -z "$editor" ]; then
        echo "No suitable editor found."
        return 1
    fi

    # Open the file with the editor
    sudo $editor "$file"
}



#
# Add the module options to the options array
# This is done last so that the module's functions are not added to the options array
# Join and split may produce multibel of the for loop here. 
#






# Start of zenity.keyboard.sh



module_options+=(
["desktop_keyboard,feature"]="serve_doc"
["desktop_keyboard,desc"]="Set User desktop keyboard layout (no sudo)"
["desktop_keyboard,example"]="desktop_keyboard"
)

desktop_keyboard() {
    zenity --info --text "GUI Test for User (non admin) preferred keyboard layout"
    sleep 2

    layout=$(zenity --entry --text "Please enter your preferred keyboard layout:")

    # Check if the user clicked Cancel or entered nothing
    if [ $? -ne 0 ] || [ -z "$layout" ]; then
        exit 1
    fi

    if grep -q "setxkbmap -layout" ~/.xinitrc; then
        sed -i '/setxkbmap -layout/d' ~/.xinitrc
    fi

    # Only append to .xinitrc if $layout is not empty
    if [ -n "$layout" ]; then
        echo "setxkbmap -layout $layout" >> ~/.xinitrc
        zenity --info --text "Command to set keyboard layout to $layout has been added to ~/.xinitrc"
    fi
}






