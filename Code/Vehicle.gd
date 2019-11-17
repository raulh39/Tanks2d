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
var _arrow_scene = preload("res://Scenes/Arrow.tscn")
var _target_cross_scene = preload("res://Scenes/TargetCross.tscn")
var woods_underneath: Area2D = null

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

func set_targetable(shooting_tank:Vehicle) -> void:
	_tank_that_want_to_shoot_us = shooting_tank
	#Look at _physics_process() for the code
	#executed after this

#warning-ignore:unused_argument
func _physics_process(delta):
	if not _tank_that_want_to_shoot_us:
		return
	_target_status = _calculate_target_status(_tank_that_want_to_shoot_us)
	match _target_status:
		TargetStatus.InCover, TargetStatus.Visible:
			_tank_that_want_to_shoot_us._draw_target_cross(global_position)
	_tank_that_want_to_shoot_us = null #No more _physics_process needed

func _calculate_target_status(shooting_tank:Vehicle) -> int:
	var target_corners_position := _get_vehicle_corners_positions(position, $HullShape.shape.extents - Vector2(5,5), rotation)
	var line_of_sight := _calculate_line_of_sight(shooting_tank, target_corners_position)
	if not line_of_sight: return TargetStatus.NotVisible
	if _calculate_target_is_in_cover(shooting_tank, target_corners_position): return TargetStatus.InCover
	return TargetStatus.Visible

static func _get_vehicle_corners_positions(v_position:Vector2, v_extents :Vector2, v_rotation: float) -> Array:
		return [
			v_position+v_extents.rotated(v_rotation),
			v_position+(v_extents*Vector2(-1,-1)).rotated(v_rotation),
			v_position+(v_extents*Vector2(1,-1)).rotated(v_rotation),
			v_position+(v_extents*Vector2(-1,1)).rotated(v_rotation)
		]

func _calculate_line_of_sight(shooting_tank:Vehicle, target_corner_positions: Array) -> bool:
	var extents_pos := _get_extents(shooting_tank.position, target_corner_positions)
	var has_los:=false
	var direct_space_state := get_world_2d().direct_space_state
	for target_pos in _get_positions_between(extents_pos.min_pos, extents_pos.max_pos):
		var collision_mask_for_woods_buildings_and_tanks = 0x07
		var excluded_objects := [shooting_tank]
		if shooting_tank.woods_underneath:
			excluded_objects.append(shooting_tank.woods_underneath)
		if woods_underneath:
			excluded_objects.append(woods_underneath)
		var collision := direct_space_state.intersect_ray(shooting_tank.position, target_pos, excluded_objects, collision_mask_for_woods_buildings_and_tanks, true, true)
		if collision.collider == self:
			shooting_tank._draw_vision_line(collision.position)
			has_los = true
	return has_los

static func _get_extents(origin_position:Vector2, target_corner_positions: Array) -> Dictionary:
	var ret := {
		min_pos=target_corner_positions[0],
		max_pos=target_corner_positions[0]
	}
	var min_angle := ((target_corner_positions[0] as Vector2)- origin_position).angle()
	var max_angle := min_angle
	
	for p in target_corner_positions:
		var ang := ((p as Vector2) - origin_position).angle()
		if ang < min_angle:
			min_angle = ang
			ret.min_pos = p
		if ang > max_angle:
			max_angle = ang
			ret.max_pos = p
	return ret

static func _get_positions_between(min_pos: Vector2, max_pos: Vector2) -> Array:
	var dir = max_pos - min_pos
	var ret = []
	for i in range(0, 20):
		ret.append(min_pos+dir*(i/20.0))
	ret.append(max_pos)
	return ret

enum CoverTokenType { Visible, Cover }

func _calculate_target_is_in_cover(shooting_tank:Vehicle, target_corner_positions: Array) -> bool:
	var direct_space_state := get_world_2d().direct_space_state
	var collision_mask_for_woods_buildings_and_tanks = 0x07
	var covered_corners: int = 0
	for corner in target_corner_positions:
		var excluded_objects := [shooting_tank, self]
		if shooting_tank.woods_underneath:
			excluded_objects.append(shooting_tank.woods_underneath)
		var collision := direct_space_state.intersect_ray(shooting_tank.position, corner, excluded_objects, collision_mask_for_woods_buildings_and_tanks, true, true)
		if not collision:
			shooting_tank._add_cover_token(corner, global_rotation, CoverTokenType.Visible)
		else:
			shooting_tank._add_cover_token(corner, global_rotation, CoverTokenType.Cover)
			covered_corners += 1
	return covered_corners >= 2

func _add_cover_token(pos: Vector2, rot: float, type: int) -> void:
	var s: Sprite = Sprite.new()
	match type:
		CoverTokenType.Visible:
			s.texture = load("res://Assets/Tokens/GreenFullCircle_50.png")
		CoverTokenType.Cover:
			s.texture = load("res://Assets/Tokens/RedCross_50.png")
	$VisionArtifacts.add_child(s)
	s.global_position = pos
	s.global_rotation = rot
	s.z_index = 15

func _draw_vision_line(global_dest_position: Vector2) -> void:
	var new_line := Line2D.new()
	new_line.default_color = Color(1,1,0, .3)
	$VisionArtifacts.add_child(new_line)
	new_line.add_point(Vector2())
	new_line.add_point((global_dest_position - $VisionArtifacts.global_position).rotated(-rotation))
	new_line.z_index = 5

func _draw_target_cross(global_dest_position: Vector2) -> void:
	var target_cross = _target_cross_scene.instance()
	$VisionArtifacts.add_child(target_cross)
	target_cross.global_rotation = 0
	target_cross.global_position = global_dest_position
	target_cross.z_index = 15

func _clean_vision_artifacts() -> void:
	for i in $VisionArtifacts.get_children():
		$VisionArtifacts.remove_child(i)
		i.queue_free()



#-------------------------------------------
# Move
#-------------------------------------------
func move_tank():
	var a: Node2D = _arrow_scene.instance()
	$HullBorderPath.add_child(a)
	a.unit_offset = 0.4 #So the arrow appear in the front side
	yield(a.move(self), "completed")
	a.queue_free()

#-------------------------------------------
# Shoot
#-------------------------------------------
func shoot_tank(target_tank: Vehicle):
	var time_out := 1.0
	if not target_tank:
		time_out = 0.05
	yield(get_tree().create_timer(time_out), "timeout")
	_clean_vision_artifacts()

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
		woods_underneath = area
		return
	_overlapping_tank_or_building += 1
	modulate = collisioning_color

func _on_Vehicle_area_exited(area: Area2D) -> void:
	if area.collision_layer == 2: #TODO: 2 is for Woods. Change that magic number
		woods_underneath = null
		return
	_overlapping_tank_or_building -= 1
	if _overlapping_tank_or_building==0:
		modulate = non_collisioning_color
