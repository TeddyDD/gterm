
extends Control

# export variables
export(int) var min_columns = 1
export(int) var min_rows = 1

export (DynamicFont) var dynamicFont

# offset of characters in cells
export(float) var font_x_offset = 0
export(float) var font_y_offset = 0

# change the size of cells
# The size of the cells is calculated based on size of "W" character
# These properties allow you to change the margin of characters
export(float) var resize_cell_x = 1
export(float) var resize_cell_y = 1


export(Color, RGBA) var foregound_default  # default text color
export(Color, RGBA) var background_default # default background color
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
	buffer = Buffer.new(grid,foregound_default,background_default, default_char)
	ready = true
	
	connect("resized", self, "_on_resize")
	
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
			font_pos.x = (x * cell.width) + (cell.width * font_x_offset)
			font_pos.y = ((y + 1) * cell.height) + (cell.height * font_y_offset)
			draw_char( font, font_pos, buffer.chars[i], "W", buffer.fgcolors[i])
			
# terminal api
# call this functions and then update()

# Set character in given cell
func write_char(x, y, char):
	check_bounds(x, y)
	assert(char.length() == 1) # this function can take only one char
	
	buffer.chars[buffer.index(Vector2(x, y))] = char
	
# Set colors of given cell
# If fg or bg == null then color will be intact
func write_color(x, y, fg, bg):
	check_bounds(x, y)
	# only one parameter can be null
	assert(fg != null or bg != null) 
	
	if fg != null:
		buffer.fgcolors[buffer.index(Vector2(x, y))] = fg
	if bg != null:
		buffer.bgcolors[buffer.index(Vector2(x, y))] = bg
	

# Helper function that ensures drawing in bounds of buffer
func check_bounds(x, y):
	assert(x >= 0 and x <= grid.x - 1)
	assert(y >= 0 and y <= grid.y - 1)

# Calculate the grid size. Final result depens of font size
func calculate_size():
	
	var width = get_size().width
	var height = get_size().height
	
	cell.width = int(font.get_string_size("W").width * resize_cell_x ) 
	cell.height = int(font.get_height() * resize_cell_y )
	
	grid.width = ( width - (int(width) % int(cell.width)) ) / cell.width
	grid.height = ( height - (int(height) % int(cell.height)) ) / cell.height

# Call manually when changed font size
func _on_resize(): # signal
	if ready:
		var old_grid = grid
		calculate_size()
		if grid.x > 0 and grid.y > 0 and old_grid != grid:
			var b = Buffer.new(grid,foregound_default,background_default, default_char)
			b.transfer_from(buffer)
			buffer = b
	update()