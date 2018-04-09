extends Control

export (Vector2) var max_cells = Vector2(100, 100)
export (DynamicFont) var font
export (Color) var fg = Color(0, 1, 0.109375)
export (Color) var bg = Color(0, 0, 0)


#####################
# Private Variables #
#####################

var _cell_size = Vector2()
var _grid_size = Vector2()
var _buffer

var _draw_c
var _draw_bg
var _draw_fg
var _draw_bg_rect = Rect2()
var _draw_font_pos = Vector2()

#####################
# Private functions #
#####################

func _ready():
	assert(font != null)
	_buffer_init()
	connect("resized", self, "_on_resize")
	
func _process(delta):
	if Input.is_action_pressed("ui_accept"):
		for y in range(50):
			for x in range(100):
				_buffer.bg[y][x] = Color(randf(), randf(), randf(), randf())
				_buffer.fg[y][x] = Color(randf(), randf(), randf(), randf())
				_buffer.chars[y][x] = '#'
		update()
	
func _buffer_init():
	_buffer = Buffer.new()
	_buffer.initialize(max_cells)
	_calculate_size()
	
func _on_resize():
	_calculate_size()
	update()
	
func _calculate_size():
	var width = get_size().x
	var height = get_size().y
	# Get size of biggest font
	# prevous max cell size
	_cell_size.x = int(font.get_string_size("W").x)
	_cell_size.y = int(font.get_height())
	
	_draw_bg_rect.size.x = _cell_size.x
	_draw_bg_rect.size.y = _cell_size.y
	
	_grid_size.x = min(( width - (int(width) % int(_cell_size.x)) ) / _cell_size.x, max_cells.x)
	_grid_size.y = min(( height - (int(height) % int(_cell_size.y)) ) / _cell_size.y, max_cells.y)

func _draw():
	var t = OS.get_ticks_msec()
	draw_rect(get_rect(), bg)
	for y in range(_grid_size.y):
		for x in range(_grid_size.x):
			_draw_c = _buffer.chars[y][x]
#			if _draw_c == null:
#				continue
			_draw_fg = _buffer.fg[y][x]
			_draw_fg = _draw_fg if _draw_fg != null else fg
			_draw_bg = _buffer.bg[y][x]
			if _draw_bg != null:
				_draw_bg_rect.position.x = x * _cell_size.x
				_draw_bg_rect.position.y = y * _cell_size.y
				draw_rect(_draw_bg_rect, _draw_bg)
			if _draw_c != null:
				_draw_font_pos.x = (x * _cell_size.x)
				_draw_font_pos.y = (y * _cell_size.y) + font.get_ascent()
				draw_char( font, _draw_font_pos, _draw_c, "W", _draw_fg)
				
	var _draw_time = (OS.get_ticks_msec() - t)
	prints(_draw_time)
			

class Buffer:
	var chars = []
	var fg = []
	var bg = []
	func initialize(size):
		for y in range(size.y):
			chars.append([])
			chars[y].resize(size.x)
			fg.append([])
			fg[y].resize(size.x)
			bg.append([])
			bg[y].resize(size.x)
