
extends Panel

var cursor = Vector2(0,0)
var terminal
var current_style

# color pickers
onready var fg_picker = get_node("VBoxContainer/HBoxContainer/fg_color")
onready var bg_picker = get_node("VBoxContainer/HBoxContainer/bg_color")

# font selector
onready var font_select = get_node("VBoxContainer/HBoxContainer/font_style")

var draw_mouse = false

func _ready():
	terminal = get_node("VBoxContainer/Terminal")
	# load additional fonts
	terminal.add_font(preload("res://fonts/Ubuntu_mono_bold.tres"))
	terminal.add_font(preload("res://fonts/Ubuntu_mono_italic.tres"))
	terminal.add_font(preload("res://fonts/Ubuntu_mono_italic_bold.tres"))
	terminal._on_resize()
	terminal.redraw_terminal()
	
	
	# current terminal style
	current_style = terminal.Style.new(fg_picker.get_color(), bg_picker.get_color(), 0)
	
	# add menu items for fonts
	font_select.add_item("Normal", 0)
	font_select.add_item("Bold", 1)
	font_select.add_item("Italic", 2)
	font_select.add_item("Bold Italic", 3)
	font_select.select(0)
	


# Enter button
func _on_enter_pressed():
	var string = get_node("VBoxContainer/HBoxContainer/LineEdit").get_text()
	cursor = terminal.write_string(cursor.x, cursor.y, string, current_style)
	

	cursor.x += 1
	if cursor.x >= terminal.grid.x - 1:
		_on_new_line_pressed()
	
	# redraw terminal 
	terminal.redraw_terminal()

# When you press enter key while writing
func _on_LineEdit_text_entered( text ):
	_on_enter_pressed()
	get_node("VBoxContainer/HBoxContainer/LineEdit").set_text("")

func resize_font(size):
	terminal.resize_fonts(size)
	terminal._on_resize()
	terminal.redraw_terminal()

# font+ button
func _on_font_plus_pressed():
	resize_font(1)

# font- button
func _on_font_minus_pressed():
	resize_font(-1)


func _on_clean_pressed():
	var c = get_node("VBoxContainer/HBoxContainer/LineEdit").get_text()
	c = c.left(1)
	if c.empty():
		c = " "
	cursor = Vector2()
	terminal.defaultStyle.bg = current_style.bg
	terminal.write_all(c, current_style)
	terminal.redraw_terminal()


func _on_font_style_item_selected( ID ):
	current_style.font = ID


func _on_fg_color_color_changed( color ):
	current_style.fg = color


func _on_bg_color_color_changed( color ):
	current_style.bg = color


func _on_new_line_pressed():
	# go to begginig of next line
	cursor.x = 0
	cursor.y += 1
	if cursor.y >= terminal.grid.y - 1:
		cursor.y = 0
	


func _on_Terminal_input_event( ev ):
	if ev.type == InputEvent.MOUSE_MOTION and draw_mouse:
		var c = terminal.get_cell(Vector2(ev.x, ev.y))
		terminal.write(c.x, c.y, "#", current_style)
		terminal.redraw_terminal()


func _on_draw_toggled( pressed ):
	draw_mouse = pressed


func _on_Panel_resized():
	if terminal != null:
		OS.set_window_title("Terminal: %s" % terminal.grid)
