tool
extends Control

# export variables

# default font
export (DynamicFont) var dynamicFont

export(Color, RGBA) var foregound_default = Color("ffffff")  # default text color
export(Color, RGBA) var background_default = Color("000000") setget _set_background_default # default background color


# offset of characters in cells
export(float) var font_x_offset = 0
export(float) var font_y_offset = 0

# change the size of cells
# The size of the cells is calculated based on size of "W" character
# These properties allow you to change the margin of characters
export(float) var resize_cell_x = 1
export(float) var resize_cell_y = 1


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

var _draw_buffer
var _draw_texture

# true if code is running inside editor
var _editor = true

var _redraw = true


####################
# Public functions #
####################

# call this functions and then update() to redraw changes.

# return cell from mouse coordinates
func get_cell(point):
	return Vector2(clamp(floor(point.x / cell.width), 0, grid.x - 1),
	               clamp(floor(point.y / cell.height), 0, grid.y - 1))

# Write character in given postion using given style
# any parameter can be null
func write(x, y, character, style=defaultStyle):
	_check_bounds(x, y)
	assert(character.length() == 1) # this function can take only one character
	var i = buffer.index(Vector2(x, y))
	buffer.damage.append(Vector2(x,y))
	if character != null:
		buffer.chars[i] = character
	if style != null:
		if style.fg != null:
			buffer.fgcolors[i] = style.fg
		if style.bg != null:
			buffer.bgcolors[i] = style.bg
		if style.font != null:
			buffer.fonts[i] = style.font

# Write string in given postion. fg and bg can be null.
# This method use simple line wrapping. 
# Returns postion of last cell of string (Vector2)
func write_string(x, y, string, style=defaultStyle):
	_check_bounds(x,y)
	assert(string != null)
	if string.length() >= buffer.get_size() - buffer.index(Vector2(x,y)):
		string = string.left(buffer.get_size() - buffer.index(Vector2(x,y)))
	
	var cursor = Vector2(x, y)
	for l in range(string.length()):
		var i = buffer.index(Vector2(cursor.x, cursor.y))
		buffer.damage.append(cursor)
		var c = string[l]
		buffer.chars[i] = c
		if style.fg != null:
			buffer.fgcolors[i] = style.fg
		if style.bg != null:
			buffer.bgcolors[i] = style.bg
		if style.font != null:
			buffer.fonts[i] = style.font
		# wrap lines
		if cursor.x >= grid.width - 1:
			cursor.y += 1
			cursor.x = 0
		elif cursor.y >= grid.height:
			cursor.y = grid.height - 1
			return cursor
		else:
			cursor.x += 1
	return cursor

# draw rectangle with given parameters
# character, fg and bg can be null
func write_rect(rect, character=null, style=defaultStyle):
	_check_bounds(rect.pos.x, rect.pos.y)
	_check_bounds(rect.end.x, rect.end.y)
	
	for y in range(rect.size.y):
		for x in range(rect.size.x):
			var i = buffer.index(Vector2(x + rect.pos.x, y + rect.pos.y))
			if character != null:
				buffer.chars[i] = character
			if style.fg != null:
				buffer.fgcolors[i] = style.fg
			if style.bg != null:
				buffer.bgcolors[i] = style.bg
			if style.font != null:
				buffer.fonts[i] = style.font
			buffer.damage.append(Vector2(x,y))

# Clean screen with given params
func write_all(character=null, style=defaultStyle):
	_draw_buffer.request_full_redraw()
	assert(style.fg != null and style.bg != null)
	buffer.set_default(character, style.fg, style.bg, style.font)

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
	_draw_buffer.request_full_redraw()
	for f in fonts:
		f.set_size(f.get_size() + delta)
		
func redraw_terminal():
	_redraw = true

#####################
# Private functions #
#####################

func _ready():
	# editor check
	_editor = get_tree().is_editor_hint()
	
	# default style
	defaultStyle = Style.new(foregound_default, background_default, 0)
	if not _editor:
		# add default font and calculate size
		defaultStyle.font = add_font(dynamicFont)
		assert(fonts != null)
		
		buffer = Buffer.new(grid,defaultStyle.fg, defaultStyle.bg, null, defaultStyle.font)
		
		connect("resized", self, "_on_resize")
		
		_draw_buffer = get_node("capture/draw buffer")
		_draw_buffer.connect("_done_rendering", self, "_render_done")
		
		_draw_buffer.mode = _draw_buffer.FULL_REDRAW
		_draw_buffer.update()
		set_process(true)
		
func _render_done(mode):
	_draw_texture = get_node("capture").get_render_target_texture()
	update()
	if mode == _draw_buffer.FULL_REDRAW:
		buffer.damage = []
	_draw_buffer.mode = _draw_buffer.DAMAGE_REDRAW
	

func _process(delta):
	if _redraw:
		_draw_buffer.update()
		_redraw = false
		

func _draw():
	if _editor:
		draw_rect(Rect2(get_global_rect().pos - get_global_pos(), get_size()), background_default)
	
	if _draw_texture != null:
		draw_texture(_draw_texture, Vector2(0,0))
	else:
		_draw_buffer.request_full_redraw()
		_draw_buffer.on_resize()
		_draw_buffer.update()
	

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
	if not _editor:
		var old_grid = grid
		_calculate_size()
		if grid.x > 0 and grid.y > 0 and old_grid != grid:
			var b = Buffer.new(grid,defaultStyle.fg, defaultStyle.bg, null)
			b.transfer_from(buffer)
			buffer = b
		_draw_buffer.mode = _draw_buffer.RESIZE_REDRAW
		_draw_buffer.on_resize()
		redraw_terminal()

	
# SetGet
# Default Bg color - only for editor
func _set_background_default(value):
	background_default = value
	if _editor:
		update()
		
