# Experiment: JSON Dialogue Box
This application is a command-line interface that interacts with a JSON file to perform various operations. It is open-source and licensed under the GPL.

The application reads a JSON file which contains a menu of commands. Each command in the menu has an associated ID and command string.

When the application starts, it generates a top-level menu from the JSON file. The user can select a command from the menu by entering the associated ID. If the user selects a command, the application executes the command.

Updated on Tue Feb 27 02:31:41 AM MST 2024.

# FEATURES: Table of Contents
| Feature | Description | Example |
| --- | --- | --- |
| get_input | TODO | get_input | TODO:|
| serve-debug | Start a simple http server to view readme.md and other files in the browser | serve_debug | TODO:|
| hold_packages | Hold firmware, kernel, and u-boot from upgrades | hold_packages | TODO:|
| show_menu | Check for internet connection | show_menu | TODO:|
| see_firmware_hold | Check if firmware, kernel, and u-boot are held back from upgrades | see_firmware_hold | TODO:|
| generate_top_menu | Generate the top menu | generate_top_menu | TODO:|
| split_files | split the monolithic file to module files | split_files "path/to/file.sh" "path/to/folder" | TODO:|
| execute_command | Execute a command | execute_command | TODO:|
| get_user_continue | Display a Yes/No dialog box (WIP) | TODO:Desc | TODO:|
| show_message | Check for internet connection | echo "message" | show_message  | TODO:|
| reset_colors | Reset the background color | reset_colors | TODO:|
| process_input | TODO:Desc | TODO:Desc | TODO:|
| unhold_packages | Unhold firmware, kernel, and u-boot from upgrades | unhold_packages | TODO:|
| generate_restricted_commands | List of restricted commands for execute_command | generate_restricted_commands | TODO:|
| get_dependencies | Install missing dependencies | get_dependencies "arg1 arg2 arg3..." | TODO:|
| consolidate_files | build a monolithic file from the module files | consolidate_files "path/to/folder" "path/to/file.sh" | TODO:|
| generate_menu | Generate the submenu | generate_menu | TODO:|
| set_colors | Set a background color | (number 0-7) | TODO:|
| show_infobox | Show info box |  TODO | TODO:|
| remove_dependencies | Remove installed dependencies | remove_dependencies "arg1 arg2 arg3..." | TODO:|
| edit_file | Edit a file with an avaliblet editor | "pth/to/file" | TODO:|
| see_use | Show in file examples | see_use | TODO:|
| set_user_input | Display a input dialog use with get_user_input |  set_user_input | get_input | TODO:|
| get_user_input | Display set_user_input results |  set_user_input | get_user_input | TODO:|
| see_ping | Check for internet connection warn if none | see_ping | TODO:|
| parse_json | Show json opjects | parse_json | TODO:|


