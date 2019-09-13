extends PathFollow2D

class_name Arrow

const VELOCITY := 0.01

signal arrow_accepted

func _input(event: InputEvent)->void:
	if event.is_action("ui_down"):
		unit_offset += VELOCITY
	elif event.is_action("ui_up"):
		unit_offset -= VELOCITY
	elif event.is_action_released("ui_accept"):

		emit_signal("arrow_accepted")
