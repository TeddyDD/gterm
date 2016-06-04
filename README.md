![](icon.png)

# Terminal for Godot

This is simple terminal emulator like control for Godot engine. It might be useful for projects like

- game about hacking/hackers
- game about programming
- game with ASCII graphics
- game when you have to interact with computers
- editor plugins
- cheat/debug console
- think of something yourself

## Screenshot
Screenshot of `demo.tscn`

![Screenshot of demo scene](https://cloud.githubusercontent.com/assets/4397533/15800472/28877386-2a7b-11e6-8b11-e4c2dc4003d0.png)

## Project Setup

For now, you have to use Godot engine built from source. At least this commit is required: https://github.com/godotengine/godot/commit/564ba76becab1819bcde1265d4f119e04a6b76ee

This project requires following Godot features:

1. Dynamic fonts loading
2. New Godot plug-in system (optional)

## Testing

Todo

## How to use

To install these, copy `terminal` to a folder `addons/`
inside your projects, like this `addons/terminal`

and then activate it in `Scene > Project Settings > Plugins`
Now you can create terminal control from `Create new Node menu`. **Not working yet**

**OR** instance `terminal.tscn` somewhere in your scene.

To distribute and install from UI, make a zip that contains the directory:

`zip -r terminal.zip terminal/*`
