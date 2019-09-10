extends Area2D

class_name Vehicle

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

var has_acted := false

var _arrow_scene = preload("res://Scenes/Arrow.tscn")

func set_selectable(var selectable: bool) -> void:
	($HullGlow as CanvasItem).visible = selectable

func _on_Vehicle_mouse_entered():
	($Hull as CanvasItem).modulate = Color.yellow

func _on_Vehicle_mouse_exited():
	($Hull as CanvasItem).modulate = Color.white

func move_tank():
	print("moving")
	var a: Node2D = _arrow_scene.instance()
	$HullBorderPath.add_child(a)
	yield(get_tree().create_timer(10), "timeout")
	a.queue_free()
	print("moved")

func shoot_tank():
	print("shooting")
	yield(get_tree().create_timer(10), "timeout")
	print("shooted")

func command_tank():
	print("commanding")
	yield(get_tree().create_timer(10), "timeout")
	print("commanded")

func total_adjusted_initiative() -> int:
	var ret :int = initiative*2
	if country == Countries.German:
		ret += 1
	return ret
