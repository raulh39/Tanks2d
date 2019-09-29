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

var has_acted := false
var overlapping_tank_or_building := false

var _selectable := false
var _arrow_scene = preload("res://Scenes/Arrow.tscn")

onready var hull = $Hull

signal vehicle_selected(vehicle)

func set_selectable(var selectable: bool) -> void:
	($HullGlow as CanvasItem).visible = selectable
	_selectable = selectable

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

func shoot_tank():
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
	if not _selectable:
		return
	var evt : InputEventMouseButton = (event as InputEventMouseButton)
	if evt.button_index == BUTTON_LEFT and not evt.pressed:
        emit_signal("vehicle_selected", self)


func _on_Vehicle_area_entered(area: Area2D):
	if area.collision_layer == 2: #TODO: 2 is for Woods. Change that magic number
		return
	overlapping_tank_or_building = true
	modulate = collisioning_color

func _on_Vehicle_area_exited(area: Area2D):
	if area.collision_layer == 2: #TODO: 2 is for Woods. Change that magic number
		return
	overlapping_tank_or_building = false
	modulate = non_collisioning_color
