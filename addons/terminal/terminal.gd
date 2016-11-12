tool
extends Control

# export variables

# default font
export (DynamicFont) var dynamicFont

# offset of characters in cells
export(float) var font_x_offset = 0
export(float) var font_y_offset = 0

# change the size of cells
# The size of the cells is calculated based on size of "W" character
# These properties allow you to change the margin of characters
export(float) var resize_cell_x = 1
export(float) var resize_cell_y = 1


export(Color, RGBA) var foregound_default = Color("ffffff")  # default text color
export(Color, RGBA) var background_default = Color("000000") # default background color
export var default_char = " " # one char

# private variables
# avaliable dynamic fonts - size of cell is based on biggest font
# 0 is usually default font
var fonts = []


var grid = Vector2() # rows and collumns
var cell = Vector2() # cell size in pixels

# libs
var Buffer = preload("res://addons/terminal/buffer.gd")
var Style = preload("res://addons/terminal/TermStyle.gd")

var buffer
var defaultStyle

####################
# Public functions #
####################

# call this functions and then update() to redraw changes.

# Write char in given postion using given style
# any parameter can be null
func write(x, y, char, style=defaultStyle):
	_check_bounds(x, y)
	assert(char.length() == 1) # this function can take only one char
	
	if char != null:
		buffer.chars[buffer.index(Vector2(x, y))] = char
	if style != null:
		if style.fg != null:
			buffer.fgcolors[buffer.index(Vector2(x, y))] = style.fg
		if style.bg != null:
			buffer.bgcolors[buffer.index(Vector2(x, y))] = style.bg
		if style.font != null:
			buffer.fonts[buffer.index(Vector2(x, y))] = style.font

# Write string in given postion. fg and bg can be null.
# This method use simple line wrapping. 
# Returns postion of last cell of string (Vector2)
func write_string(x, y, string, style=defaultStyle):
	_check_bounds(x,y)
	assert(string != null)
	
	var cursor = Vector2(x, y)
	for l in range(string.length()):
		var i = buffer.index(Vector2(cursor.x, cursor.y))
		var c = string[l]
		buffer.chars[i] = c
		if style.fg != null:
			buffer.fgcolors[i] = style.fg
		if style.bg != null:
			buffer.bgcolors[i] = style.bg
		if style.font != null:
			buffer.fonts[i] = style.font
		# wrap lines
		if cursor.x >= grid.width:
			cursor.y += 1
			cursor.x = 0
		elif cursor.y >= grid.height:
			cursor.y = grid.height - 1
			return cursor
		else:
			cursor.x += 1
	return cursor

# draw rectangle with given parameters
# char, fg and bg can be null
func write_rect(rect, char=null, style=defaultStyle):
	_check_bounds(rect.pos.x, rect.pos.y)
	_check_bounds(rect.end.x, rect.end.y)
	
	for y in range(rect.size.y):
		for x in range(rect.size.x):
			var i = buffer.index(Vector2(x + rect.pos.x, y + rect.pos.y))
			if char != null:
				buffer.chars[i] = char
			if style.fg != null:
				buffer.fgcolors[i] = style.fg
			if style.bg != null:
				buffer.bgcolors[i] = style.bg
			if style.font != null:
				buffer.fonts[i] = style.font

# Clean screen with given params
func write_all(char=default_char, style=defaultStyle):
	assert(char != null and style.fg != null and style.bg != null)
	buffer.set_default(char, style.fg, style.bg, style.font)

# add font to fonts array and calulate size
# returns ID of font
func add_font(f):
	assert(f.get_type() == "DynamicFont")
	fonts.append(f)
	_calculate_size()
	# return id of added font
	return fonts.size() - 1
	
# resize all fonts
func resize_fonts(delta):
	for f in fonts:
		var new_size = f.get_size() + delta
		f.set_size(new_size)

#####################
# Private functions #
#####################

func _ready():
	# default style
	defaultStyle = Style.new(foregound_default, background_default, 0)

	# add default font and calculate size
	defaultStyle.font = add_font(dynamicFont)
	assert(fonts != null)
	
	buffer = Buffer.new(grid,defaultStyle.fg, defaultStyle.bg, default_char, defaultStyle.font)
	
	connect("resized", self, "_on_resize")
	update()

func _draw():
	# draw background
	draw_rect(get_rect(), defaultStyle.bg)
	# draw letters and boxes
	for y in range(grid.height):
		for x in range(grid.width):
			var i = buffer.index(Vector2(x,y))
			
			# draw bg
			var bg_rect = Rect2(x * cell.width, y * cell.height, cell.width, cell.height)
			draw_rect(bg_rect, buffer.bgcolors[i])
			
			# draw text
			var font_pos = Vector2()
			var font_now = fonts[buffer.fonts[i]]
			font_pos.x = (x * cell.width) + (cell.width * font_x_offset)
			font_pos.y = (y * cell.height) + font_now.get_ascent() + (cell.height * font_y_offset)
			draw_char( font_now, font_pos, buffer.chars[i], "W", buffer.fgcolors[i])
			

# Helper function that ensures drawing in bounds of buffer
func _check_bounds(x, y):
	assert(x >= 0 and x <= grid.x - 1)
	assert(y >= 0 and y <= grid.y - 1)
	
# Calculate the grid size. Final result depens of font size
func _calculate_size():
	
	var width = get_size().width
	var height = get_size().height

	# Get size of biggest font
	# prevous max cell size
	var c = Vector2() 
	for f in fonts:
		cell.width = max( int(f.get_string_size("W").width * resize_cell_x ), c.width)
		cell.height = max( int(f.get_height() * resize_cell_y ), c.height)
		# I want a copy, not reference
		c = cell + Vector2(0,0)
	
	grid.width = ( width - (int(width) % int(cell.width)) ) / cell.width
	grid.height = ( height - (int(height) % int(cell.height)) ) / cell.height

# Call manually when changed font size
func _on_resize(): # signal
	var old_grid = grid
	_calculate_size()
	if grid.x > 0 and grid.y > 0 and old_grid != grid:
		var b = Buffer.new(grid,defaultStyle.fg, defaultStyle.bg, default_char)
		b.transfer_from(buffer)
		buffer = b
	update()
	
	