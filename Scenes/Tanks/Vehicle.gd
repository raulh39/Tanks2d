extends Area2D


func _on_Vehicle_mouse_entered():
	$HullGlow.visible = true
	$Hull.modulate = Color.yellow


func _on_Vehicle_mouse_exited():
	$HullGlow.visible = false
	$Hull.modulate = Color.white