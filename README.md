# Expriment
JSON DIALOGUE BOX

## limitations
### Supported dialog box:
- whiptail supported
- dialog devlopment partly supported.
- read not emplimented

### requierments
- basic check
- does not install TODO
- missing requierments show warning message

### show hide
- manualy set TODO handeling

### Interface
- Ok message box
- TOP Menu box
- Sub Menu box
- Started help message

### Color suported terminals
- error code `$?` colors
- catagoryy colors
  

# Application Name

This application is a command-line interface that interacts with a JSON file to perform various operations.

## How it works

The application reads a JSON file which contains a menu of commands. Each command in the menu has an associated ID and command string.

When the application starts, it generates a top-level menu from the JSON file. The user can select a command from the menu by entering the associated ID.

If the user selects a command, the application executes the command. 

## network shown here has 1 hidden menu item
See "show": true or false
![image](https://cdn.discordapp.com/attachments/1196019315074400346/1196021029382922260/animation.gif?ex=65b61c62&is=65a3a762&hm=3e30b65f7e42266b1e848e3cea611517de9448d1a5eed08ed1f0979efa3efb1c&)

## JSON file format

The JSON file should be an array of objects, where each object represents a menu item. Each object should have an `id` property and a `command` property. The `id` property is a string that the user can enter to select the command, and the `command` property is the command string that the application will execute.

Here's an example of what the JSON file might look like:

```json
{
    "menu": [
        {
            "id": "System",
            "description": "System Security Options",
            "sub": [
                {
                    "id": "S1",
                    "description": "Test Echo",
                    "command": "echo 'Hello World'",
                    "show": true,
                    "requirements": []
                },
                {
                    "id": "S2",
                    "description": "Test Echo2",
                    "command": "echo 'Hello Armbian'",
                    "show": false,
                    "requirements": []
                }
            ]
        },
        {
            "id": "Network",
            "description": "Network Options",
            "sub": [
                {
                    "id": "N1",
                    "description": "Wi-fi connect to network",
                    "command": "nmtui connect",
                    "show": true,
                    "requirements": ["nmtui"]
                },
                {
                    "id": "N2",
                    "description": "network manager tui",
                    "command": "nmtui",
                    "show": true,
                    "requirements": ["nmtui"]
                },
                {
                    "id": "N3",
                    "description": "Wi-fi connect to network",
                    "command": "nmtui connect",
                    "show": false,
                    "requirements": ["nmtui"]
                }
            ]
        },
        {
            "id": "Aplications",
            "description": "Software instalation Options",
            "sub": [
                {
                    "id": "A1",
                    "description": "Updtate apt repository",
                    "command": "apt update",
                    "show": true,
                    "requirements": ["apt"]
                },
                {
                    "id": "A2",
                    "description": "Provides simple CLI monitoring - scrolling output",
                    "command": "armbianmonitor -m",
                    "show": false,
                    "requirements": ["armbianmonitor"]
                },
                {
                    "id": "A3",
                    "description": "Provides simple CLI monitoring - scrolling output",
                    "command": "armbianmonitor -m",
                    "show": true,
                    "requirements": ["armbianmonitor"]
                }
            ]
        },
        {
            "id": "Localisation",
            "description": "Locale Language Region Time Keyboard",
            "sub": [
                {
                    "id": "L1",
                    "description": "Change Local Timezone",
                    "command": "sudo timedatectl set-timezone",
                    "show": true,
                    "requirements": ["timedatectl"]
                }
            ]
        },
        {
            "id": "Help",
            "description": "About this app",
            "sub": [
                {
                    "id": "H1",
                    "description": "Armbian Config Help",
                    "command": "bash armbian-config --help",
                    "show": true,
                    "requirements": ["armbian-config"]
                },                {
                    "id": "H2",
                    "description": "Armbian Configng Help",
                    "command": "bash armbian-configng --help",
                    "show": true,
                    "requirements": ["armbian-configng --help"]
                }
            ]
        }
    ]
}
```

