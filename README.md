# Experiment: JSON Dialogue Box

This application is a command-line interface that interacts with a JSON file to perform various operations. It is open-source and licensed under the GPL.

The application reads a JSON file which contains a menu of commands. Each command in the menu has an associated ID and command string.

When the application starts, it generates a top-level menu from the JSON file. The user can select a command from the menu by entering the associated ID. If the user selects a command, the application executes the command.

## Included is a editor 

See [configng.edit doc](https://github.com/Tearran/retro-configng/blob/main/configng.edit.md)
![JSON Editor](https://github.com/Tearran/retro-configng/assets/2831630/d1dbd9b4-ea53-49ed-814f-62e05010e16f)

## Limitations

### Supported dialog box:
- `whiptail` fully supported
- `dialog` development partly supported
- `read` not implemented

### Show/Hide Menu Items
- Visibility of menu items must be manually set in the JSON file (TODO automatic handling)

### Interface
- OK message box
- Top Menu box
- Sub Menu box
- Started help message

This project is licensed under the GPL.
