extends Node2D

signal vehicle_selected(tank)

func _ready():
	for i in get_children():
		if i is Vehicle:
			var v := (i as Vehicle)
			v.connect("vehicle_selected", self, "_vehicle_selected")

#------------------
# Tanks come into play in initiative order. In the movement phase they go from 
# lower initiative to higher but in the shooting phase they go from higher to 
# lower.
# As Godot still hasn't got lambdas, we must make two static functions, "gt" and 
# "lt" just to order the tanks in one way or the other.
#------------------
static func lt(x:int , y: int) -> bool:
    return x < y

static func gt(x:int , y: int) -> bool:
    return x > y

#-----------------------------------------
# Tanks movement
#-----------------------------------------
func move_tanks() -> void:
	_reset_acted()
	while _more_to_act():
		var tank:Vehicle = yield(_select_tank_by_initiative(funcref(self, "lt")), "completed")
		yield(tank.move_tank(), "completed")
		tank.has_acted = true

func _reset_acted()->void:
	for i in get_children():
		(i as Vehicle).has_acted = false

func _more_to_act() -> bool:
	for i in get_children():
		if not (i as Vehicle).has_acted:
			return true
	return false

#----------------
# Tanks are selected in initiative order. If only one has the greatest (or 
# lowest) initiative, that is selected. But if more than one has the same 
# greatest (or lowest) initiative the user should select one of them.
# We must, in that case, wait until the user clicks in one of the selectable
# tanks, that is, we must wait for the signal "vehicle_selected". So we
# must use "yield" to wait until that signal is sent.
#----------------
func _select_tank_by_initiative(comparator: FuncRef) -> Vehicle:
	var tanks_allowed_to_act := _get_next_group_to_act(comparator)
	var tank: Vehicle
	if tanks_allowed_to_act.size() > 1:
		tank = yield(_select(tanks_allowed_to_act), "completed") as Vehicle
	else:
		#If this branch doesn't yield, the returned object is not a coroutine and the code doesn't works
		#so we have to fake a yield.
		yield(get_tree().create_timer(0.05), "timeout")
		tank = tanks_allowed_to_act.front() as Vehicle
	return tank

#Returns the array of tanks with higher (or lower) inititive.
func _get_next_group_to_act(comparator: FuncRef) -> Array:
	var ret := []
	var ret_initiative: int
	var one_children_found: bool = false
	for i in get_children():
		assert(i is Vehicle)
		var child: Vehicle = (i as Vehicle)
		if not child.has_acted:
			if not one_children_found or comparator.call_func(child.total_adjusted_initiative(), ret_initiative):
				one_children_found = true
				ret = [ child ]
				ret_initiative = child.total_adjusted_initiative()
			elif child.total_adjusted_initiative() == ret_initiative:
				ret.append(child)
	return ret

#Waits until the user clicks in one of the tanks passed in the parameter
func _select(tanks_allowed_to_act: Array)->void:
	for i in tanks_allowed_to_act:
		(i as Vehicle).set_selectable(true)
	var vehicle = yield(self, "vehicle_selected")
	for i in tanks_allowed_to_act:
		(i as Vehicle).set_selectable(false)
	return vehicle

func _vehicle_selected(vehicle):
	emit_signal("vehicle_selected", vehicle)

	
#-----------------------------------------
# Tanks shooting
#-----------------------------------------
func shoot_with_tanks() -> void:
	_reset_acted()
	while _more_to_act():
		var shooting_tank:Vehicle = yield(_select_tank_by_initiative(funcref(self, "gt")), "completed")
		shooting_tank.set_shooting(true)
		var target_tank:Vehicle = yield(_select_target_tank(shooting_tank), "completed")
		shooting_tank.set_shooting(false)
		if target_tank:
			yield(shooting_tank.shoot_tank(target_tank), "completed")
		shooting_tank.has_acted = true

#Needed to handle input "ui_cancel"
var _waiting_to_select_target: bool

func _input(event: InputEvent)->void:
	if _waiting_to_select_target and event.is_action_released("ui_cancel"):
		emit_signal("vehicle_selected", null)

func _select_target_tank(shooting_tank:Vehicle) -> Vehicle:
	_set_targetable_tanks(shooting_tank, true)
	_waiting_to_select_target = true
	var vehicle = yield(self, "vehicle_selected")
	_waiting_to_select_target = false
	_set_targetable_tanks(shooting_tank, false)
	return vehicle

func _set_targetable_tanks(shooting_tank:Vehicle, targetable: bool) -> void:
	for i in get_children():
		if i is Vehicle:
			var v := (i as Vehicle)
			if v.country != shooting_tank.country:
				if targetable:
					v.set_targetable(shooting_tank)
				else:
					v.unset_targetable()

#-----------------------------------------
# Tanks command
#-----------------------------------------
func command_tanks() -> void:
	for i in get_children():
		(i as Vehicle).set_movement_token(0)
	yield(get_tree().create_timer(1), "timeout")
