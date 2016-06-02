extends Reference

var size # size of buffer: Vector2

var chars    # array of chars
var fgcolors # foreground (text) colors
var bgcolors # background colors

# Create buffer of given size_c_r (Vector2D, columns, rows) and fill with default values
# empty_char by default is " " (space)
func _init(size_c_r, fg, bg, empty_char):
	if not empty_char:
		empty_char == " "
	size = size_c_r
		# initialize arrays
	chars = []
	fgcolors = []
	bgcolors = []
	set_default(" ",fg,bg)

# returns index for given column and row
func index(point):
	var column = point.x
	var row = point.y
	return row * size.width + column
	
func get_size():
	return size.x * size.y

func transfer_from(buffer):
	for y in range(1, buffer.size.y + 1):
		if y <= size.y:
			for x in range(1, buffer.size.x + 1):
				if x <= size.x:
					var i = index(Vector2(x,y))
					chars[i] = buffer.chars[i]
					fgcolors[i] = buffer.fgcolors[i]
					bgcolors[i] = buffer.bgcolors[i]

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
