
extends Panel

var cursor = Vector2(0,0)
onready var terminal = get_node("VBoxContainer/Terminal")

# color pickers
onready var fg_picker = get_node("VBoxContainer/HBoxContainer/fg_color")
onready var bg_picker = get_node("VBoxContainer/HBoxContainer/bg_color")

func _ready():
	fg_picker.set_color(terminal.foregound_default)
	bg_picker.set_color(terminal.background_default)

# Enter button
func _on_enter_pressed():
	var string = get_node("VBoxContainer/HBoxContainer/LineEdit").get_text()
	for i in range(string.length()):
		# wrap lines
		if cursor.x >= terminal.grid.width:
			cursor.y += 1
			cursor.x = 0
		# go back to first line (no scrolling yet)
		if cursor.y >= terminal.grid.height:
			cursor = Vector2(0,0)
		# write char using terminal api (they are set in buffer but not drawn yet)
		terminal.write_char(cursor.x, cursor.y, string[i])
		cursor.x += 1
	
	# go to begginig of next line
	cursor.x = 0
	cursor.y += 1
	
	# redraw terminal 
	terminal.update()

# When you press enter key while writing
func _on_LineEdit_text_entered( text ):
	_on_enter_pressed()
	get_node("VBoxContainer/HBoxContainer/LineEdit").set_text("")
