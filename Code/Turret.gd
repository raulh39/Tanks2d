extends Sprite

class_name Turret

var shooting := false

#warning-ignore:unused_argument
func _process(delta:float)->void:
	if not shooting:
		return
	var angle_to_mouse_pos := get_local_mouse_position().angle()
	rotation += angle_to_mouse_pos
