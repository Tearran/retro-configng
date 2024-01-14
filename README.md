# Expriment
JSON DIALOGUE BOX

# Application Name

This application is a command-line interface that interacts with a JSON file to perform various operations.

## How it works

The application reads a JSON file which contains a menu of commands. Each command in the menu has an associated ID and command string.

When the application starts, it generates a top-level menu from the JSON file. The user can select a command from the menu by entering the associated ID.

If the user selects a command, the application executes the command. 
![animation](https://github.com/Tearran/retro-configng/assets/2831630/fa3b24e9-c971-4c86-a4c4-8a82eb78f5d6)

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
                    "show": true,
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
                    "description": "Change Locale",
                    "command": "bash armbian-config --help",
                    "show": true,
                    "requirements": ["bash", "armbian-config"]
                }
            ]
        }
    ]
}
```

