Usage: 
  TODO:DESC
	get_input TODO:Example

  Start a simple http server
	serve-debug serve_debug

  Hold firmware, kernel, and u-boot from upgrades
	hold_packages TODO:Example

  Check for internet connection
	show_menu TODO:Example

  Check if firmware, kernel, and u-boot are held back from upgrades
	see_firmware_hold TODO:Example

  split the monolithic file to module files
	split_files split_files "path/to/file.sh" "path/to/folder"

  Execute a command from the array
	execute_command (WIP)

  Display a Yes/No dialog box (WIP)
	get_user_continue get_user_continue

  Check for internet connection
	show_message TODO:Example

  TODO:Desc
	process_input process_input

  Unhold firmware, kernel, and u-boot from upgrades
	unhold_packages TODO:Example

  Install missing dependencies
	get_dependencies get_dependencies "arg1 arg2 arg3..."

  build a monolithic file from the module files
	consolidate_files consolidate_files "path/to/folder" "path/to/file.sh"

  Set a background color
	set_colors (number 0-7)

  Show info box
	show_infobox TODO:Example

  Remove installed dependencies
	rm-deps remove_dependencies "arg1 arg2 arg3..."

  Edit a file with an avaliblet editor
	edit_file "pth/to/file"

  Show in file examples
	see_use see_use

  Display a input dialog
	set_user_input set_user_input

  Display set_user_input results
	get_user_input get_user_input

  Check for internet connection
	see_ping 

  Show readble json
	parse_json parse_json


Menu ID: Run Time
Menu Description: Functions Play ground
  Submenu ID: T0
  Submenu Description: Check Colors (testing)
  Submenu Command: [
  "get_user_continue \"This will iterate 8 colors \nDo you want to continue?\" process_input",
  "for i in {0..7}; do set_colors $i && echo Color code $i | show_infobox; done;",
  "clear && set_colors 0",
  " echo 'Colors 0-7 test complete' | show_message ;"
]
  Submenu Show: true
  Submenu Network: null
  Submenu Requirements: 

  Submenu ID: T1
  Submenu Description: Software apt repository updtate
  Submenu Command: [
  "get_user_continue \"This will check when apt was updated and if ts running \nDo you want to continue?\" process_input",
  "see_current_apt | show_message ; "
]
  Submenu Show: true
  Submenu Network: null
  Submenu Requirements: 

  Submenu ID: T2
  Submenu Description: See ping, see apt, & see firmware  (testing)
  Submenu Command: [
  "get_user_continue \"$( see_ping ) \n Continue?\" process_input",
  "get_user_continue \"$( see_current_apt ) \nContinue?\" process_input",
  "get_user_continue \"$( see_firmware_hold ) \nContinue?\" process_input"
]
  Submenu Show: true
  Submenu Network: null
  Submenu Requirements: 

  Submenu ID: T3
  Submenu Description: Pipe armbianmonitor -m to show_infobox
  Submenu Command: [
  "armbianmonitor -m | show_infobox"
]
  Submenu Show: true
  Submenu Network: null
  Submenu Requirements: 

Menu ID: Network
Menu Description: Wireless, Ethernet, and Network settings
  Submenu ID: N0
  Submenu Description: Manage wifi network connections
  Submenu Command: [
  "nmtui connect"
]
  Submenu Show: true
  Submenu Network: null
  Submenu Requirements: nmtui

Menu ID: Localisation
Menu Description: Locale Language Region Time Keyboard
  Submenu ID: L1
  Submenu Description: Change Local Timezone (WIP)
  Submenu Command: [
  "timedatectl set-timezone "
]
  Submenu Show: true
  Submenu Network: null
  Submenu Requirements: timedatectl

Menu ID: Help
Menu Description: About this app
  Submenu ID: H0
  Submenu Description: Example Show in file Uses (WIP)
  Submenu Command: [
  "see_use | show_message"
]
  Submenu Show: true
  Submenu Network: null
  Submenu Requirements: 

  Submenu ID: H1
  Submenu Description: Example Uses (WIP)
  Submenu Command: [
  "parse_json | show_message"
]
  Submenu Show: true
  Submenu Network: null
  Submenu Requirements: 

  Submenu ID: H3
  Submenu Description: Armbian Config Help (WIP)
  Submenu Command: [
  "bash armbian-config --help |  show_message"
]
  Submenu Show: true
  Submenu Network: null
  Submenu Requirements: 

