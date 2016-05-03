
extends Control

# export variables
export(int) var min_columns = 1
export(int) var min_rows = 1

export (DynamicFont) var dynamicFont

# offset of characters in cells
export(int) var font_x_offset = 0
export(int) var font_y_offset = 0

# change the size of cells
# The size of the cells is calculated based on size of "W" character
# These properties allow you to change the margin of characters
export(int) var resize_cell_x = 0
export(int) var resize_cell_y = 0


export(Color, RGB) var foregound_default  # default text color
export(Color, RGB) var background_default # default background color

# private variables
var font

var grid = Vector2() # rows and collumns
var cell = Vector2() # cell size in pixels

func _ready():
	font = dynamicFont
	update()

func _draw():
	draw_rect(get_rect(), Color(1,1,1,1))

func get_minimum_size(): # override
	# TODO
	return Vector2(100,100)
	
func _on_resize(): # signal
	prints("Size ",get_size())

