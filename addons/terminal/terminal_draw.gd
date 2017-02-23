extends Control

const FULL_REDRAW = 1
const DAMAGE_REDRAW = 2
const RESIZE_REDRAW = 3
var mode = 1

# debug
var _draw_time = 0

var term
signal _done_rendering(mode)

func _ready():
	term = get_parent().get_parent()
	term.connect("resized", self, "on_resize")
	set_size(term.get_size())

	
func request_full_redraw():
	mode = FULL_REDRAW

func on_resize():
	get_parent().set_rect(Rect2(Vector2(), get_size()))
	set_size(term.get_size())
	

func _draw():
	var t = OS.get_ticks_msec()
	if term._draw_texture != null and mode == DAMAGE_REDRAW:
		term._draw_texture = get_parent().get_render_target_texture()
		draw_texture(term._draw_texture, Vector2())
		on_resize()
		damage_redraw()
		emit_signal("_done_rendering", DAMAGE_REDRAW)
#	elif term._draw_texture != null and mode == RESIZE_REDRAW:
#		draw_bg()
#		term._draw_texture = get_parent().get_render_target_texture()
#		draw_texture_rect_region(term._draw_texture, term.get_rect(), Rect2(Vector2(), term.get_size()))
#		mode = DAMAGE_REDRAW
#		emit_signal("_done_rendering", RESIZE_REDRAW)
	else: # full redraw
		draw_bg()
		full_redraw()
		term._draw_texture = get_parent().get_render_target_texture()
		emit_signal("_done_rendering", FULL_REDRAW)
	term.buffer.damage = []
	_draw_time = (OS.get_ticks_msec() - t)
	

func draw_bg():
	draw_rect(get_rect(), term.defaultStyle.bg)
	
func full_redraw():
	# variables for loop
	var char_now
	var fgcolor_now
	var font_now
	var font_pos = Vector2()
	var bg_rect = Rect2(0,0, term.cell.width, term.cell.height)
	var w = term.buffer.size.width
	var default_font = term.defaultStyle.font
	var cell = term.cell
	var fonts = term.buffer.fonts
	var chars = term.buffer.chars
	var fg = term.buffer.fgcolors
	var bg = term.buffer.bgcolors
	var def_bg = term.defaultStyle.bg
		
	# draw letters and boxes
	# index
	var i = 0
	var x = 0
	var y = 0
	var end = term.buffer.get_size()
	var size = term.buffer.size.width
	
	while (i < end):
			# draw bg
			if bg[i] != null or bg[i] != def_bg:
				bg_rect.pos.x = x * cell.width
				bg_rect.pos.y = y * cell.height
				draw_rect(bg_rect, bg[i])
			# draw text
			char_now = chars[i]
			if char_now != null	:
				if char_now != " ":
					if not fonts[i] == null:
						font_now = term.fonts[fonts[i]]
					else:
						font_now = term.fonts[term.defaultStyle.font]
						
					fgcolor_now = fg[i]
					if fgcolor_now == null:
						fgcolor_now = fonts[term.defaultStyle.font]
							
					font_pos.x = (x * cell.width) + (cell.width * term.font_x_offset)
					font_pos.y = (y * cell.height) + font_now.get_ascent() + (cell.height * term.font_y_offset)
					draw_char( font_now, font_pos, char_now, "W", fgcolor_now)
			i += 1
			x += 1
			if x == size:
				x = 0
				y += 1
			
func damage_redraw():
	var x
	var y
	var i
	
	# variables for loop
	var char_now
	var fgcolor_now
	var font_now
	var font_pos = Vector2()
	var bg_rect = Rect2(0,0, term.cell.width, term.cell.height)
	var w = term.buffer.size.width
	var default_font = term.defaultStyle.font
	var cell = term.cell
	var fonts = term.buffer.fonts
	var chars = term.buffer.chars
	var fg = term.buffer.fgcolors
	var bg = term.buffer.bgcolors
	var def_bg = term.defaultStyle.bg
	for indx in term.buffer.damage:
		
		x = indx.x
		y = indx.y
		i = y * w + x
	
		# draw bg
		if bg[i] != null or bg[i] != def_bg:
			bg_rect.pos.x = x * cell.width
			bg_rect.pos.y = y * cell.height
			draw_rect(bg_rect, bg[i])
		# draw text
		char_now = chars[i]
		if char_now != null:
			if char_now != " ":
				if not fonts[i] == null:
					font_now = term.fonts[fonts[i]]
				else:
					font_now = term.fonts[term.defaultStyle.font]
					
				fgcolor_now = fg[i]
				if fgcolor_now == null:
					fgcolor_now = fonts[term.defaultStyle.font]
						
				font_pos.x = (x * cell.width) + (cell.width * term.font_x_offset)
				font_pos.y = (y * cell.height) + font_now.get_ascent() + (cell.height * term.font_y_offset)
				draw_char( font_now, font_pos, char_now, "W", fgcolor_now)

