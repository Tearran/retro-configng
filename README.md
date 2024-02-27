# Experiment: Retro-config
This application is a command-line interface that perform various operations. It is open-source and licensed under the GPL.
 
Updated on Tue Feb 27 03:22:41 AM MST 2024.

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

Available commands:
--readme   -	Update the Features table
--json     -	Show json like format of the features
--join     -	Merge the module files into one file
--split    -	Split the module file into multiple files
--help     -	Show this help message

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

# JSON: Object
## Opject generated by said associtive array
"generate_json" function in retro-config script
~~~ 
[
  {
    "feature": "get_input",
    "description": "TODO",
    "example": "get_input"
  },
  {
    "feature": "serve-debug",
    "description": "",
    "example": ""
  },
  {
    "feature": "hold_packages",
    "description": "Hold firmware, kernel, and u-boot from upgrades",
    "example": "hold_packages"
  },
  {
    "feature": "show_menu",
    "description": "Check for internet connection",
    "example": "show_menu"
  },
  {
    "feature": "see_firmware_hold",
    "description": "Check if firmware, kernel, and u-boot are held back from upgrades",
    "example": "see_firmware_hold"
  },
  {
    "feature": "generate_top_menu",
    "description": "Generate the top menu",
    "example": "generate_top_menu"
  },
  {
    "feature": "split_files",
    "description": "split the monolithic file to module files",
    "example": "split_files "path/to/file.sh" "path/to/folder""
  },
  {
    "feature": "execute_command",
    "description": "Execute a command",
    "example": "execute_command"
  },
  {
    "feature": "get_user_continue",
    "description": "Display a Yes/No dialog box (WIP)",
    "example": "TODO:Desc"
  },
  {
    "feature": "show_message",
    "description": "Check for internet connection",
    "example": "echo "message" | show_message "
  },
  {
    "feature": "reset_colors",
    "description": "Reset the background color",
    "example": "reset_colors"
  },
  {
    "feature": "process_input",
    "description": "TODO:Desc",
    "example": "TODO:Desc"
  },
  {
    "feature": "unhold_packages",
    "description": "Unhold firmware, kernel, and u-boot from upgrades",
    "example": "unhold_packages"
  },
  {
    "feature": "generate_restricted_commands",
    "description": "List of restricted commands for execute_command",
    "example": "generate_restricted_commands"
  },
  {
    "feature": "get_dependencies",
    "description": "Install missing dependencies",
    "example": "get_dependencies "arg1 arg2 arg3...""
  },
  {
    "feature": "consolidate_files",
    "description": "build a monolithic file from the module files",
    "example": "consolidate_files "path/to/folder" "path/to/file.sh""
  },
  {
    "feature": "generate_menu",
    "description": "Generate the submenu",
    "example": "generate_menu"
  },
  {
    "feature": "set_colors",
    "description": "Set a background color",
    "example": "(number 0-7)"
  },
  {
    "feature": "show_infobox",
    "description": "Show info box",
    "example": " TODO"
  },
  {
    "feature": "remove_dependencies",
    "description": "Remove installed dependencies",
    "example": "remove_dependencies "arg1 arg2 arg3...""
  },
  {
    "feature": "edit_file",
    "description": "Edit a file with an avaliblet editor",
    "example": ""pth/to/file""
  },
  {
    "feature": "see_use",
    "description": "Show in file examples",
    "example": "see_use"
  },
  {
    "feature": "set_user_input",
    "description": "Display a input dialog use with get_user_input",
    "example": " set_user_input | get_input"
  },
  {
    "feature": "get_user_input",
    "description": "Display set_user_input results",
    "example": " set_user_input | get_user_input"
  },
  {
    "feature": "see_ping",
    "description": "Check for internet connection warn if none",
    "example": "see_ping"
  },
  {
    "feature": "parse_json",
    "description": "Show json opjects",
    "example": "parse_json"
  }
]

~~~

