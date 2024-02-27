# Experiment: JSON Dialogue Box
This application is a command-line interface that interacts with a JSON file to perform various operations. It is open-source and licensed under the GPL.

The application reads a JSON file which contains a menu of commands. Each command in the menu has an associated ID and command string.

When the application starts, it generates a top-level menu from the JSON file. The user can select a command from the menu by entering the associated ID. If the user selects a command, the application executes the command.

Updated on Mon Feb 26 11:31:15 AM MST 2024.

# FEATURES: Table of Contents
| Feature | Description | Example |
| --- | --- | --- |
| get_input | TODO:DESC | TODO:Example | TODO:|
| serve-debug | Start a simple http server | serve_debug | TODO:|
| hold_packages | Hold firmware, kernel, and u-boot from upgrades | TODO:Example | TODO:|
| show_menu | Check for internet connection | TODO:Example | TODO:|
| see_firmware_hold | Check if firmware, kernel, and u-boot are held back from upgrades | TODO:Example | TODO:|
| split_files | split the monolithic file to module files | split_files "path/to/file.sh" "path/to/folder" | TODO:|
| execute_command | Execute a command from the array | (WIP) | TODO:|
| get_user_continue | Display a Yes/No dialog box (WIP) | get_user_continue | TODO:|
| show_message | Check for internet connection | TODO:Example | TODO:|
| process_input | TODO:Desc | process_input | TODO:|
| unhold_packages | Unhold firmware, kernel, and u-boot from upgrades | TODO:Example | TODO:|
| get_dependencies | Install missing dependencies | get_dependencies "arg1 arg2 arg3..." | TODO:|
| consolidate_files | build a monolithic file from the module files | consolidate_files "path/to/folder" "path/to/file.sh" | TODO:|
| set_colors | Set a background color | (number 0-7) | TODO:|
| show_infobox | Show info box | TODO:Example | TODO:|
| rm-deps | Remove installed dependencies | remove_dependencies "arg1 arg2 arg3..." | TODO:|
| edit_file | Edit a file with an avaliblet editor | "pth/to/file" | TODO:|
| see_use | Show in file examples | see_use | TODO:|
| set_user_input | Display a input dialog | set_user_input | TODO:|
| get_user_input | Display set_user_input results | get_user_input | TODO:|
| see_ping | Check for internet connection |  | TODO:|
| parse_json | Show readble json | parse_json | TODO:|


