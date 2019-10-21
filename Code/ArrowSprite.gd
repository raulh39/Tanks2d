extends Sprite

#warning-ignore:unused_argument
func _process(delta:float)->void:
	var angle_to_mouse_pos := get_local_mouse_position().angle()
	rotation += angle_to_mouse_pos
