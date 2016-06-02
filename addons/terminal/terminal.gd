
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

var Buffer = preload("res://addons/terminal/buffer.gd")
var buffer

var ready = false

func _ready():
	font = dynamicFont
	assert(font != null)

	calculate_size()
	prints(grid)
	buffer = Buffer.new(grid,foregound_default,background_default," ")
	ready = true
	update()

func _draw():
	draw_rect(get_rect(), background_default)

# Calculate the grid size. Final result depens of font size
func calculate_size():
	
	var width = get_size().width
	var height = get_size().height
	
	cell.width = int(font.get_string_size("W").width) + resize_cell_x
	cell.height = int(font.get_height()) + resize_cell_y
	prints("Width",font.get_string_size("W").width)
	prints("Height",font.get_height())
	
	grid.width = ( width - (int(width) % int(cell.width)) ) / cell.width
	grid.height = ( height - (int(height) % int(cell.height)) ) / cell.height

func get_minimum_size(): # override
	# TODO
	return Vector2(100,100)

# Call manually when changed font size
func _on_resize(): # signal
	if ready:
		prints("Size ",get_size())
		if font != null:
			calculate_size()
		if grid.x > 0 and grid.y > 0:
			var b = Buffer.new(grid,foregound_default,background_default," ")
			b.transfer_from(buffer)
			buffer = b
	update()