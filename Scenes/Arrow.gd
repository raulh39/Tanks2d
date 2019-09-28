extends PathFollow2D

class_name Arrow

const VELOCITY := 0.01
const SHADOW_VELOCITY = 10

signal arrow_accepted

enum Status { INACTIVE, POSITIONING_ARROW, POSITIONING_TANK }

enum Positions { LEFT, RIGHT}
enum Facings { FRONT, SIDE, BACK }
 
var status: int = Status.INACTIVE
var ghost_position: int = Positions.LEFT
var ghost_facing: int = Facings.FRONT

var half_arrow_height:int = 30
var _tank
var _tank_parent
var _arrow_parent
var half_tank_height: int
var half_tank_width: int
var _last_offset: float

func _input(event: InputEvent)->void:
	match status:
		Status.POSITIONING_ARROW:
			if event.is_action("ui_down"):
				unit_offset += VELOCITY
			elif event.is_action("ui_up"):
				unit_offset -= VELOCITY
			elif event.is_action_released("ui_accept"):
				emit_signal("arrow_accepted")
		Status.POSITIONING_TANK:
			if event.is_action("ui_down"):
				_tank.position.x -= SHADOW_VELOCITY
			elif event.is_action("ui_up"):
				_tank.position.x += SHADOW_VELOCITY
			elif event.is_action_pressed("ui_left"):
				_change_tank_position()
			elif event.is_action_pressed("ui_right"):
				_change_tank_facing()
			elif event.is_action_released("ui_accept"):
				emit_signal("arrow_accepted")

func move(new_tank)-> void:
	_tank = new_tank
	_tank_parent = new_tank.get_parent()
	_arrow_parent = self.get_parent()
	var tank_size = new_tank.hull.get_rect().size
	half_tank_height = tank_size.y/2
	half_tank_width = tank_size.x/2
	yield(_move_step(), "completed")
	yield(_move_step(), "completed")
	status = Status.INACTIVE

# Initial distribution:
# _tank_parent (main.tscn)
#     |
#   _tank
#     |
#  _arrow_parent (_tank.$HullBorderPath)
#     |       
#   self
#     |
#  $ArrowSprite
#
# End distribution
# _tank_parent (main.tscn)
#     |
#   self
#     |
#  $ArrowSprite
#     |
#   _tank
#     |
#  _arrow_parent (_tank.$HullBorderPath)
func _reparent_tank_under_arrow()->void:
	var initial_arrow_global_pos = self.global_position
	_arrow_parent.remove_child(self)
	_tank_parent.add_child(self)
	self.global_position = initial_arrow_global_pos
	
	_tank_parent.remove_child(_tank)
	$ArrowSprite.add_child(_tank)
	_tank.position.x=0
	_place_tank()
	_last_offset = self.offset

func _reparent_tank_over_arrow()->void:
	var initial_tank_global_pos = _tank.global_position
	var initial_tank_global_rot = _tank.global_rotation
	$ArrowSprite.remove_child(_tank)
	_tank_parent.add_child(_tank)
	_tank.global_rotation = initial_tank_global_rot
	_tank.global_position = initial_tank_global_pos
	
	_tank_parent.remove_child(self)
	_arrow_parent.add_child(self)
	self.offset = _last_offset

func _move_step() -> void:
	status = Status.POSITIONING_ARROW
	yield(self, "arrow_accepted")
	status = Status.POSITIONING_TANK
	_reparent_tank_under_arrow()
	yield(self, "arrow_accepted")
	_reparent_tank_over_arrow()

func _change_tank_facing() -> void:
	if ghost_facing == Facings.BACK:
		ghost_facing = Facings.FRONT
	else:
		ghost_facing += 1
	_place_tank()

func _change_tank_position() -> void:
	if ghost_position == Positions.LEFT:
		ghost_position = Positions.RIGHT
	else:
		ghost_position = Positions.LEFT
	_place_tank()

func _place_tank() -> void:
	var half_tank_dimension: int
	match ghost_facing:
		Facings.FRONT:
			_tank.rotation = 0
			half_tank_dimension = half_tank_height
		Facings.BACK:
			_tank.rotation = PI
			half_tank_dimension = half_tank_height
		Facings.SIDE:
			if ghost_position == Positions.LEFT:
				_tank.rotation = -PI/2
			else:
				_tank.rotation = PI/2
			half_tank_dimension = half_tank_width
	
	match ghost_position:
		Positions.LEFT:
			_tank.position.y = -(half_arrow_height + half_tank_dimension)
		Positions.RIGHT:
			_tank.position.y = +(half_arrow_height + half_tank_dimension)
