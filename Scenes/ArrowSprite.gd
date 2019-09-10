extends Sprite

func _process(delta:float)->void:
	var angle_to_mouse_pos := get_local_mouse_position().angle()
	rotation += angle_to_mouse_pos
