extends Reference

var size # size of buffer: Vector2

var chars    # array of chars
var fgcolors # foreground (text) colors
var bgcolors # background colors

# Create buffer of given size_c_r (Vector2D, columns, rows) and fill with default values
# empty_char by default is " " (space)
func _init(size_c_r, fg, bg, empty_char=" "):
	size = size_c_r
		# initialize arrays
	chars = []
	fgcolors = []
	bgcolors = []
	set_default(empty_char,fg,bg)

# returns index for given column and row
func index(point):
	var column = point.x
	var row = point.y
	return row * size.width + column
	
func get_size():
	return size.x * size.y

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

func set_default(c, fg, bg):
	# resize buffers
	var b = size.width * size.height
	
	chars.resize(b)
	fgcolors.resize(b)
	bgcolors.resize(b)
	
	# set default variables
	for item in range( b ):
		chars[item] = c
		fgcolors[item] = fg
		bgcolors[item] = bg
