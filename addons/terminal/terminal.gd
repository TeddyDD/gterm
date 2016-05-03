
extends Control

# export variables
export(int) var min_columns = 1
export(int) var min_rows = 1

export (DynamicFont) var dynamicFont

# private variables
var font

func _ready():
	font = dynamicFont
	update()

func _draw():
	draw_rect(get_rect(), Color(1,1,1,1))

func get_minimum_size(): # override
	# TODO
	return Vector2(100,100)
	
func _on_resize(): # signal
	prints("Size ",get_size())

