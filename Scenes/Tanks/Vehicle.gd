extends Area2D

enum Countries {
	German,
	British,
	American,
	Soviet
}

enum Abilities {
	gung_ho,
	blitzkrieg
}

export (String) var tank_name
export (Countries) var country
export (int, 0, 200) var point_value
export (int, 0, 10) var initiative
export (int, 0, 6) var attack
export (int, 0, 6) var defense
export (int, 0, 6) var damage_capacity
export (Array, Abilities) var abilities = []

func _on_Vehicle_mouse_entered():
	$HullGlow.visible = true
	$Hull.modulate = Color.yellow


func _on_Vehicle_mouse_exited():
	$HullGlow.visible = false
	$Hull.modulate = Color.white