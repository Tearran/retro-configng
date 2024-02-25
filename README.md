# Menu ID: Run Time
## Menu Description: Functions Play ground
- Submenu ID: T0
- Submenu Description: Check Colors (testing)
- Submenu Command: 
         [
  "get_user_continue \"This will iterate 8 colors \nDo you want to continue?\" process_input",
  "for i in {0..7}; do set_colors $i && echo Color code $i | show_infobox; done;",
  "clear && set_colors 0",
  " echo 'Colors 0-7 test complete' | show_message ;"
]
Submenu Show: true
Submenu Network: null
Submenu Requirements:  

- Submenu ID: T1
- Submenu Description: Software apt repository updtate
- Submenu Command: 
         [
  "get_user_continue \"This will check when apt was updated and if ts running \nDo you want to continue?\" process_input",
  "see_current_apt | show_message ; "
]
Submenu Show: true
Submenu Network: null
Submenu Requirements:  

- Submenu ID: T2
- Submenu Description: See ping, see apt, & see firmware  (testing)
- Submenu Command: 
         [
  "get_user_continue \"$( see_ping ) \n Continue?\" process_input",
  "get_user_continue \"$( see_current_apt ) \nContinue?\" process_input",
  "get_user_continue \"$( see_firmware_hold ) \nContinue?\" process_input"
]
Submenu Show: true
Submenu Network: null
Submenu Requirements:  

- Submenu ID: T3
- Submenu Description: Pipe armbianmonitor -m to show_infobox
- Submenu Command: 
         [
  "armbianmonitor -m | show_infobox"
]
Submenu Show: true
Submenu Network: null
Submenu Requirements:  

# Menu ID: Network
## Menu Description: Wireless, Ethernet, and Network settings
- Submenu ID: N0
- Submenu Description: Manage wifi network connections
- Submenu Command: 
         [
  "nmtui connect"
]
Submenu Show: true
Submenu Network: null
Submenu Requirements: nmtui 

# Menu ID: Localisation
## Menu Description: Locale Language Region Time Keyboard
- Submenu ID: L1
- Submenu Description: Change Local Timezone (WIP)
- Submenu Command: 
         [
  "timedatectl set-timezone "
]
Submenu Show: true
Submenu Network: null
Submenu Requirements: timedatectl 

# Menu ID: Help
## Menu Description: About this app
- Submenu ID: H0
- Submenu Description: Example Show in file Uses (WIP)
- Submenu Command: 
         [
  "see_use | show_message"
]
Submenu Show: true
Submenu Network: null
Submenu Requirements:  

- Submenu ID: H1
- Submenu Description: Example Uses (WIP)
- Submenu Command: 
         [
  "parse_json | show_message"
]
Submenu Show: true
Submenu Network: null
Submenu Requirements:  

- Submenu ID: H3
- Submenu Description: Armbian Config Help (WIP)
- Submenu Command: 
         [
  "bash armbian-config --help |  show_message"
]
Submenu Show: true
Submenu Network: null
Submenu Requirements:  

