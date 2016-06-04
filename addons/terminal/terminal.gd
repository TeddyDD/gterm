
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
export var default_char = " " # one char

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
	buffer = Buffer.new(grid,foregound_default,background_default, default_char)
	ready = true
	update()

func _draw():
	# draw background
	draw_rect(get_rect(), background_default)
	# draw letters and boxes
	for y in range(grid.height):
		for x in range(grid.width):
			var i = buffer.index(Vector2(x,y))
			
			# draw bg
			var bg_rect = Rect2(x * cell.width, y * cell.height, cell.width, cell.height)
			draw_rect(bg_rect, buffer.bgcolors[i])
			
			# draw text
			var font_pos = Vector2()
			font_pos.x = (x * cell.width) + font_x_offset
			font_pos.y = ((y + 1) * cell.height) + font_y_offset
			draw_char( font, font_pos, buffer.chars[i], "W", buffer.fgcolors[i])
			
# terminal api
# call this functions and then update()

# Set character in given cell
func write_char(x, y, char):
	buffer.chars[buffer.index(Vector2(x, y))] = char
	
# Set colors of given cell
func write_color(x, y, fg, bg):
	buffer.fgcolors[buffer.index(Vector2(x, y))] = fg
	buffer.bgcolors[buffer.index(Vector2(x, y))] = bg
	

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

# Call manually when changed font size
func _on_resize(): # signal
	if ready:
		var old_grid = grid
		prints("Size ",get_size())
		if font != null:
			calculate_size()
		if grid.x > 0 and grid.y > 0 and old_grid != grid:
			var b = Buffer.new(grid,foregound_default,background_default, default_char)
			b.transfer_from(buffer)
			buffer = b
	update()