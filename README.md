# Terminal for Godot

This is simple terminal emulator like control for Godot engine.

## Project Setup

For now you have to use Godot engine built from source. At least this commit is required: https://github.com/godotengine/godot/commit/564ba76becab1819bcde1265d4f119e04a6b76ee

This project requires:

1. New Godot plug-in system
2. Dynamic fonts loading

## Testing

Todo

## How to use

To install these, copy `terminal` to a folder:

`addons/`

inside your projects, example:

`addons/custom_node`

and activat it in Scene > `Project Settings > Plugins`

To distribute and install from UI, make a zip that contains the folder,
example:

`zip -r terminal.zip terminal/*`
