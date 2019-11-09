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
var _my_target_cross
var _arrow_scene = preload("res://Scenes/Arrow.tscn")
var _target_cross_scene = preload("res://Scenes/TargetCross.tscn")

onready var hull = $Hull

signal vehicle_selected(vehicle)

#-------------------------------------------
# Mouse in/out functions
#-------------------------------------------
func _on_Vehicle_mouse_entered():
	($Hull as CanvasItem).modulate = Color.yellow

func _on_Vehicle_mouse_exited():
	($Hull as CanvasItem).modulate = Color.white

#-------------------------------------------
# Functions dealing with tank state (selecting, targeting and shooting)
#-------------------------------------------
func set_selectable(var selectable: bool) -> void:
	($HullGlow as CanvasItem).visible = selectable
	_selectable = selectable

func set_shooting(is_shooting: bool)->void:
	if $Hull.get_child_count() > 0 and $Hull.get_child(0) is Turret:
		$Hull.get_child(0).shooting = is_shooting


#-------------------------------------------
# Being shoot related functions.
# We need to calculate if the shooting tank has line of 
# sight (LoS) to ourselves. We want to use RayCast for 
# that. But the raycast functions can only be used in 
# the physic thread, that is, in the _physics_process() 
# function.
# So when sombody is trying to target ourselves, we 
# store the shooting tank in the variable 
# _tank_that_want_to_shoot_us.
# The _physics_process() will return inmediately if this
# variable is null, but if the variable is not null it:
#   - will do all the raycasting 
#   - will set some variables to represent the result of
#      the raycast (not visible, in-cover or visible)
#   - will set _tank_that_want_to_shoot_us to null in 
#      order to not recalculate again the same values
#-------------------------------------------

var _tank_that_want_to_shoot_us:Vehicle = null

enum TargetStatus {
	NotShooting,
	NotVisible,
	InCover,
	Visible
}

var _target_status = TargetStatus.NotShooting

func unset_targetable()-> void:
	match _target_status:
		TargetStatus.NotShooting:
			return
		TargetStatus.NotVisible:
			return
		TargetStatus.InCover:
			pass #TODO
		TargetStatus.Visible:
			get_parent().remove_child(_my_target_cross)
			_my_target_cross.queue_free()
			_my_target_cross = null

func set_targetable(shooting_tank:Vehicle) -> void:
	_tank_that_want_to_shoot_us = shooting_tank
	#Look at _physics_process() for the code
	#executed after this

func _physics_process(delta):
	if not _tank_that_want_to_shoot_us:
		return
	_target_status = _calculate_target_status(_tank_that_want_to_shoot_us)
	_tank_that_want_to_shoot_us = null #No more _physics_process needed
	match _target_status:
		TargetStatus.InCover:
			pass #TODO
		TargetStatus.Visible:	
			_my_target_cross = _target_cross_scene.instance()
			_my_target_cross.global_position = self.global_position
			_my_target_cross.global_rotation = 0
			get_parent().add_child(_my_target_cross)
			_tank_that_want_to_shoot_us=null

func _calculate_target_status(shooting_tank:Vehicle) -> int:
	var direct_space_state := get_world_2d().direct_space_state
	var collision := direct_space_state.intersect_ray(shooting_tank.position, position, [shooting_tank], collision_mask, true, true)
	shooting_tank._draw_vision_line(collision.position)
	return TargetStatus.Visible

func _draw_vision_line(global_dest_position: Vector2) -> void:
	var new_line := Line2D.new()
	new_line.default_color = Color(1,1,0, .3)
	add_child(new_line)
	new_line.add_point(Vector2())
	new_line.add_point((global_dest_position - global_position).rotated(-rotation))

func _clean_vision_lines():
	for i in get_children():
		if i is Line2D:
			remove_child(i)
			i.queue_free()

#-------------------------------------------
# Move
#-------------------------------------------
func move_tank():
	var a: Node2D = _arrow_scene.instance()
	$HullBorderPath.add_child(a)
	a.unit_offset = 0.4 #So the arrow appeard in the from side
	yield(a.move(self), "completed")
	a.queue_free()

#-------------------------------------------
# Shoot
#-------------------------------------------
func shoot_tank(target_tank: Vehicle):
	var time_out := 1
	if not target_tank:
		time_out = 0.05
	yield(get_tree().create_timer(time_out), "timeout")
	_clean_vision_lines()

#-------------------------------------------
# Command
#-------------------------------------------
func command_tank():
	set_movement_token(0)

#-------------------------------------------
# Functions called from other Nodes
#-------------------------------------------
func total_adjusted_initiative() -> int:
	var ret :int = initiative*2
	if country == Countries.German:
		ret += 1
	return ret

func set_movement_token(value: int)->void:
	if value <= 0:
		$MovementToken.texture = null
		return
	if value > movement_tokens.size():
		return
	$MovementToken.texture = movement_tokens[value-1]

func get_rect()->Rect2:
	return $Hull.get_rect()

#-------------------------------------------
# Handling of mouse click
#-------------------------------------------
#warning-ignore:unused_argument
#warning-ignore:unused_argument
func _input_event(viewport: Object, event: InputEvent, shape_idx: int) -> void:
	if not event is InputEventMouseButton:
		return
	if not _selectable and _target_status != TargetStatus.Visible and _target_status != TargetStatus.InCover:
		return
	var evt : InputEventMouseButton = (event as InputEventMouseButton)
	if evt.button_index == BUTTON_LEFT and not evt.pressed:
		emit_signal("vehicle_selected", self)

#-------------------------------------------
# Handling of overlapping (used by Arrow.gd)
#-------------------------------------------
func is_overlapping()->bool:
	return _overlapping_tank_or_building != 0

func _on_Vehicle_area_entered(area: Area2D) -> void:
	if area.collision_layer == 2: #TODO: 2 is for Woods. Change that magic number
		return
	_overlapping_tank_or_building += 1
	modulate = collisioning_color

func _on_Vehicle_area_exited(area: Area2D) -> void:
	if area.collision_layer == 2: #TODO: 2 is for Woods. Change that magic number
		return
	_overlapping_tank_or_building -= 1
	if _overlapping_tank_or_building==0:
		modulate = non_collisioning_color
