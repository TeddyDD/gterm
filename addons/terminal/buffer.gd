extends Reference

var size # size of buffer: Vector2

var chars    # array of chars
var fgcolors # foreground (text) colors
var bgcolors # background colors
var fonts    # font IDs

var damage = []

# Create buffer of given size_c_r (Vector2D, columns, rows) and fill with default values
# char by default is " " (space)
func _init(size, fg, bg, character=" ", font_id=0, set_defaults=true):
	self.size = size
	# initialize arrays
	chars = []
	fgcolors = []
	bgcolors = []
	fonts = []
	
	# resize buffers
	var b = get_size()
	
	chars.resize(b)
	fgcolors.resize(b)
	bgcolors.resize(b)
	fonts.resize(b)
	
	if set_defaults:
		set_default(character,fg,bg, font_id)

# return index for given column and row
func index(x, y):
	return y * size.x + x
	
# return column and row for given point
func get_point(index):
	return Vector2(int(index) % int(size.y), int(index/size.y))
	
func get_size():
	return size.x * size.y

func transfer_from(buffer):
	for y in range(size.y):
		if y < buffer.size.y:
				for x in range(size.x):
					if x < buffer.size.x:
						var i = index(x,y) # new
						var j = buffer.index(x,y) # old
						# new      # old
						chars[i]    = buffer.chars[j]
						fgcolors[i] = buffer.fgcolors[j]
						bgcolors[i] = buffer.bgcolors[j]
						fonts[i] = buffer.fonts[j]
						
func set_default(character, fg, bg, font_id):
	# set default variables
	for item in range( get_size() ):
		chars[item] = character
		fgcolors[item] = fg
		bgcolors[item] = bg
		fonts[item] = font_id
		
