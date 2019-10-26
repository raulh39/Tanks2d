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
export var collisioning_color: Color
export var non_collisioning_color: Color
export (Array, Texture) var movement_tokens = []

var has_acted := false
var _overlapping_tank_or_building := 0

var _selectable := false
var _targetable := false
var _my_target_cross
var _arrow_scene = preload("res://Scenes/Arrow.tscn")
var _target_cross_scene = preload("res://Scenes/TargetCross.tscn")

onready var hull = $Hull

signal vehicle_selected(vehicle)

func set_selectable(var selectable: bool) -> void:
	($HullGlow as CanvasItem).visible = selectable
	_selectable = selectable

func set_targetable(var targetable: bool) -> void:
	_targetable = targetable
	if targetable:
		_my_target_cross = _target_cross_scene.instance()
		_my_target_cross.global_position = self.global_position
		_my_target_cross.global_rotation = 0
		get_parent().add_child(_my_target_cross)
	else:
		get_parent().remove_child(_my_target_cross)
		_my_target_cross.queue_free()
		_my_target_cross = null

func _on_Vehicle_mouse_entered():
	($Hull as CanvasItem).modulate = Color.yellow

func _on_Vehicle_mouse_exited():
	($Hull as CanvasItem).modulate = Color.white

func move_tank():
	var a: Node2D = _arrow_scene.instance()
	$HullBorderPath.add_child(a)
	a.unit_offset = 0.4

	yield(a.move(self), "completed")
	a.queue_free()

func mark_shooting(is_shooting: bool)->void:
	if $Hull.get_child_count() > 0 and $Hull.get_child(0) is Turret:
		$Hull.get_child(0).shooting = is_shooting
	
func shoot_tank(target_tank: Vehicle):
	print("SHOOOOOOT to " + str(target_tank))
	print("target_tank.get_rect(): ", target_tank.get_rect(), " position: ", target_tank.get_rect().position, " end: ", target_tank.get_rect().end)
	yield(get_tree().create_timer(5), "timeout")

func command_tank():
	yield(get_tree().create_timer(5), "timeout")

func total_adjusted_initiative() -> int:
	var ret :int = initiative*2
	if country == Countries.German:
		ret += 1
	return ret

#warning-ignore:unused_argument
#warning-ignore:unused_argument
func _input_event(viewport: Object, event: InputEvent, shape_idx: int) -> void:
	if not event is InputEventMouseButton:
		return
	if not _selectable and not _targetable:
		return
	var evt : InputEventMouseButton = (event as InputEventMouseButton)
	if evt.button_index == BUTTON_LEFT and not evt.pressed:
        emit_signal("vehicle_selected", self)


func _on_Vehicle_area_entered(area: Area2D):
	if area.collision_layer == 2: #TODO: 2 is for Woods. Change that magic number
		return
	_overlapping_tank_or_building += 1
	modulate = collisioning_color

func _on_Vehicle_area_exited(area: Area2D):
	if area.collision_layer == 2: #TODO: 2 is for Woods. Change that magic number
		return
	_overlapping_tank_or_building -= 1
	if _overlapping_tank_or_building==0:
		modulate = non_collisioning_color

func set_movement_token(value: int)->void:
	if value <= 0:
		$MovementToken.texture = null
		return
	if value > movement_tokens.size():
		return
	$MovementToken.texture = movement_tokens[value-1]

func is_overlapping()->bool:
	return _overlapping_tank_or_building != 0

func get_rect()->Rect2:
	return $Hull.get_rect()
