extends PathFollow2D

class_name Arrow

const VELOCITY := 0.01

func _input(event: InputEvent)->void:
	if event.is_action("ui_down"):
		unit_offset += VELOCITY
	if event.is_action("ui_up"):
		unit_offset -= VELOCITY
