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
# default font id
var font = 0

var grid = Vector2() # rows and collumns
var cell = Vector2() # cell size in pixels

# libs
var Buffer = preload("res://addons/terminal/buffer.gd")
var Style = preload("res://addons/terminal/TermStyle.gd")

var buffer
var defaultStyle

func _ready():
	# add default font and calculate size
	font = add_font(dynamicFont)
	assert(fonts != null)
	
	buffer = Buffer.new(grid,foregound_default,background_default, default_char, font)
	
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
			draw_char( fonts[buffer.fonts[i]], font_pos, buffer.chars[i], "W", buffer.fgcolors[i])
			
# terminal api
# call this functions and then update()

# Set character in given cell
func write_char(x, y, char):
	check_bounds(x, y)
	assert(char.length() == 1) # this function can take only one char
	
	buffer.chars[buffer.index(Vector2(x, y))] = char
	
# Set font in given cell
func write_font(x, y, font_id):
	check_bounds(x, y)
	buffer.fonts[buffer.index(Vector2(x,y))] = font_id
	
# Set colors of given cell
# If fg or bg == null then color will be intact
func write_color(x, y, fg=null, bg=null):
	check_bounds(x, y)
	# only one parameter can be null
	assert(fg != null or bg != null) 
	
	if fg != null:
		buffer.fgcolors[buffer.index(Vector2(x, y))] = fg
	if bg != null:
		buffer.bgcolors[buffer.index(Vector2(x, y))] = bg

# Write string in given postion. fg and bg can be null.
# This method use simple line wrapping. 
# Returns postion of last cell of string (Vector2)
func write_string(x, y, string, fg=null, bg=null, font_id=font):
	check_bounds(x,y)
	assert(string != null)
	
	var cursor = Vector2(x, y)
	for l in range(string.length()):
		var i = buffer.index(Vector2(cursor.x, cursor.y))
		var c = string[l]
		buffer.chars[i] = c
		buffer.fonts[i] = font_id
		if fg != null:
			buffer.fgcolors[i] = fg
		if bg != null:
			buffer.bgcolors[i] = bg
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
# c, fg and bg can be null
func write_rect(rect,c=null,fg=null,bg=null, font_id=null):
	check_bounds(rect.pos.x, rect.pos.y)
	check_bounds(rect.end.x, rect.end.y)
	
	for y in range(rect.size.y):
		for x in range(rect.size.x):
			var i = buffer.index(Vector2(x + rect.pos.x, y + rect.pos.y))
			if c != null:
				buffer.chars[i] = c
			if fg != null:
				buffer.fgcolors[i] = fg
			if bg != null:
				buffer.bgcolors[i] = bg
			if font_id != null:
				buffer.fonts[i] = font_id

# Clean screen with given params
func write_all(c=default_char, fg=foregound_default, bg=background_default, font_id=font):
	assert(c != null and fg != null and bg != null)
	buffer.set_default(c, fg, bg, font_id)

# Helper function that ensures drawing in bounds of buffer
func check_bounds(x, y):
	assert(x >= 0 and x <= grid.x - 1)
	assert(y >= 0 and y <= grid.y - 1)
	
# add font to fonts array and calulate size
func add_font(f):
	assert(f.get_type() == "DynamicFont")
	fonts.append(f)
	calculate_size()
	# return id of added font
	return fonts.size() - 1

# Calculate the grid size. Final result depens of font size
func calculate_size():
	
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

# resize all fonts
func resize_fonts(delta):
	for f in fonts:
		var new_size = f.get_size() + delta
		f.set_size(new_size)


# Call manually when changed font size
func _on_resize(): # signal
	var old_grid = grid
	calculate_size()
	if grid.x > 0 and grid.y > 0 and old_grid != grid:
		var b = Buffer.new(grid,foregound_default,background_default, default_char)
		b.transfer_from(buffer)
		buffer = b
	update()
	


