extends Node2D

func _get_tanks_min_initiative() -> Array:
	var ret := []
	var min_initiative: int = 1000;
	for i in get_children():
		assert(i is Vehicle)
		var child: Vehicle = (i as Vehicle)
		if not child.has_acted:
			if child.total_adjusted_initiative() < min_initiative:
				ret = [ child ]
				min_initiative = child.total_adjusted_initiative()
			elif child.total_adjusted_initiative() == min_initiative:
				ret.append(child)
	return ret

func _reset_acted()->void:
	for i in get_children():
		(i as Vehicle).has_acted = false

func _more_to_act() -> bool:
	for i in get_children():
		if not (i as Vehicle).has_acted:
			return true
	return false

func move_tanks() -> void:
	_reset_acted()
	while _more_to_act():
		var tanks_allowed_to_move := _get_tanks_min_initiative()
		for t in tanks_allowed_to_move:
			var tank : Vehicle = (t as Vehicle)
			tank.set_selectable(true)
		for t in tanks_allowed_to_move:
			var tank : Vehicle = (t as Vehicle)
			yield(tank.move_tank(), "completed")
			tank.has_acted = true
			tank.set_selectable(false)

func shoot_with_tanks() -> void:
	yield(get_tree().create_timer(1), "timeout")

func command_tanks() -> void:
	yield(get_tree().create_timer(1), "timeout")
