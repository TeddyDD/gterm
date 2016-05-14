extends Reference

var size # size of buffer: Vector2

var chars    # array of chars
var fgcolors # foreground (text) colors
var bgcolors # background colors

# Create buffer of given size (Vector2D) and fill with default values
# empty_char by default is " " (space)
func _init(size, fg, bg, empty_char):
	if not empty_char:
		empty_char == " "
	size = size
		# initialize arrays
	chars = []
	fgcolors = []
	bgcolors = []
	set_default(" ",fg,bg)

# returns index for given column and row
func index(point):
	var column = point.x
	var row = point.y
	return ((row-1) * size.width) + (column - 1)
	
func transfer_to(buffer):
	for y in buffer.size.y:
		if y <= size.y:
			for x in buffer.size.x:
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
