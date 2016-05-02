
extends Control

func _ready():
	update()

func _draw():
	draw_rect(get_rect(), Color(1,1,1,1))

func get_minimum_size(): # override
	# TODO
	return Vector2(100,100)
	
func _on_resize(): # signal
	prints("Size ",get_size())
