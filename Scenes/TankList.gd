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

static func lt(x:int , y: int) -> bool:
    return x < y

static func gt(x:int , y: int) -> bool:
    return x > y

func _get_tanks_by_initiative() -> Array:
	var ret := []
	var ret_initiative: int
	var one_children_found: bool = false
	for i in get_children():
		assert(i is Vehicle)
		var child: Vehicle = (i as Vehicle)
		if not child.has_acted:
			if not one_children_found or child.total_adjusted_initiative() < ret_initiative:
				one_children_found = true
				ret = [ child ]
				ret_initiative = child.total_adjusted_initiative()
			elif child.total_adjusted_initiative() == ret_initiative:
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

func _select(tanks_allowed_to_move: Array)->void:
	for i in tanks_allowed_to_move:
		(i as Vehicle).set_selectable(true)
	_connect()
	var vehicle = yield(self, "vehicle_selected")
	_disconnect()
	return vehicle

func _get_next_tank():
	var tanks_allowed_to_move := _get_tanks_by_initiative()
	var tank: Vehicle
	if tanks_allowed_to_move.size() > 1:
		tank = yield(_select(tanks_allowed_to_move), "completed") as Vehicle
	else:
		#If this branch doesn't yield, the returned object is not a corroutine and the code doesn't works
		#so we have to fake a yield.
		yield(get_tree().create_timer(0.05), "timeout")
		tank = tanks_allowed_to_move.front() as Vehicle
	tank.set_selectable(false)
	return tank

func move_tanks() -> void:
	_reset_acted()
	while _more_to_act():
		var tank:Vehicle = yield(_get_next_tank(), "completed")
		yield(tank.move_tank(), "completed")
		tank.has_acted = true

func shoot_with_tanks() -> void:
	yield(get_tree().create_timer(1), "timeout")

func command_tanks() -> void:
	for i in get_children():
		(i as Vehicle).set_movement_token(0)
	yield(get_tree().create_timer(1), "timeout")
