extends Reference

var size # size of buffer: Vector2

var chars    # array of chars
var fgcolors # foreground (text) colors
var bgcolors # background colors
var fonts    # font IDs

# Create buffer of given size_c_r (Vector2D, columns, rows) and fill with default values
# char by default is " " (space)
func _init(size, fg, bg, char=" ", font_id=0, set_defaults=true):
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
		set_default(char,fg,bg, font_id)

# returns index for given column and row
func index(point):
	var column = point.x
	var row = point.y
	return row * size.width + column
	
func get_size():
	return size.width * size.height

func transfer_from(buffer):
	for y in range(size.height):
		if y < buffer.size.height:
				for x in range(size.width):
					if x < buffer.size.width:
						var i = index(Vector2(x,y)) # new
						var j = buffer.index(Vector2(x,y)) # old
						# new      # old
						chars[i]    = buffer.chars[j]
						fgcolors[i] = buffer.fgcolors[j]
						bgcolors[i] = buffer.bgcolors[j]
						fonts[i] = buffer.fonts[j]
						
func set_default(char, fg, bg, font_id):
	# set default variables
	for item in range( get_size() ):
		chars[item] = char
		fgcolors[item] = fg
		bgcolors[item] = bg
		fonts[item] = font_id
		
