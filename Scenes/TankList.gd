extends Node2D

signal vehicle_selected(tank)

func _connect():
	for t in get_children():
		(t as Vehicle).connect("vehicle_selected", self, "_vehicle_selected")
func _disconnect():
	for t in get_children():
		(t as Vehicle).disconnect("vehicle_selected", self, "_vehicle_selected")

func _vehicle_selected(vehicle):
	emit_signal("vehicle_selected", vehicle)

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
		var t
		if tanks_allowed_to_move.size() > 1:
			for i in tanks_allowed_to_move:
				(i as Vehicle).set_selectable(true)
			_connect()
			t = yield(self, "vehicle_selected")
			_disconnect()
		else:
			t = tanks_allowed_to_move.front()
		var tank : Vehicle = (t as Vehicle)
		tank.set_selectable(false)
		yield(tank.move_tank(), "completed")
		tank.has_acted = true

func shoot_with_tanks() -> void:
	yield(get_tree().create_timer(1), "timeout")

func command_tanks() -> void:
	for i in get_children():
		(i as Vehicle).set_movement_token(0)
	yield(get_tree().create_timer(1), "timeout")
