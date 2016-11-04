
extends Panel

var cursor = Vector2(0,0)
onready var terminal = get_node("VBoxContainer/Terminal")
var current_style

# color pickers
onready var fg_picker = get_node("VBoxContainer/HBoxContainer/fg_color")
onready var bg_picker = get_node("VBoxContainer/HBoxContainer/bg_color")

# font selector
onready var font_select = get_node("VBoxContainer/HBoxContainer/font_style")

func _ready():
	# load additional fonts
	terminal.add_font(preload("res://fonts/Ubuntu_mono_bold.tres"))
	terminal.add_font(preload("res://fonts/Ubuntu_mono_italic.tres"))
	terminal.add_font(preload("res://fonts/Ubuntu_mono_italic_bold.tres"))
	terminal._on_resize()
	
	# add menu items for fonts
	font_select.add_item("Normal", 0)
	font_select.add_item("Bold", 1)
	font_select.add_item("Italic", 2)
	font_select.add_item("Bold Italic", 3)
	font_select.select(0)
	
	fg_picker.set_color(terminal.foregound_default)
	bg_picker.set_color(terminal.background_default)
	
	# current terminal style
	current_style = terminal.Style.new(fg_picker.get_color(), bg_picker.get_color(), 0)

# Enter button
func _on_enter_pressed():
	var string = get_node("VBoxContainer/HBoxContainer/LineEdit").get_text()
	cursor = terminal.write_string(cursor.x, cursor.y, string, current_style)
	
	# go to begginig of next line
	cursor.x = 0
	cursor.y += 1
	if cursor.y >= terminal.grid.y - 1:
		cursor.y = 0
	
	# redraw terminal 
	terminal.update()

# When you press enter key while writing
func _on_LineEdit_text_entered( text ):
	_on_enter_pressed()
	get_node("VBoxContainer/HBoxContainer/LineEdit").set_text("")

func resize_font(size):
	terminal.resize_fonts(size)
	terminal._on_resize()

# font+ button
func _on_font_plus_pressed():
	resize_font(1)

# font- button
func _on_font_minus_pressed():
	resize_font(-1)


func _on_clean_pressed():
	var c = get_node("VBoxContainer/HBoxContainer/LineEdit").get_text()
	c = c.left(1)
	cursor = Vector2()
	terminal.defaultStyle.bg = current_style.bg
	terminal.write_all(c, current_style)
	terminal.update()

func _on_font_style_item_selected( ID ):
	current_style.font = ID


func _on_fg_color_color_changed( color ):
	current_style.fg = color


func _on_bg_color_color_changed( color ):
	current_style.bg = color
