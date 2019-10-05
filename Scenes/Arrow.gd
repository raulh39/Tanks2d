extends PathFollow2D

class_name Arrow

const VELOCITY := 0.01
const SHADOW_VELOCITY = 10
const HALF_ARROW_HEIGHT:int = 30
const ARROW_WIDTH:int = 485

signal arrow_accepted

enum _Status { INACTIVE, POSITIONING_ARROW, POSITIONING_TANK }
enum _Positions { LEFT, RIGHT}
enum _Facings { FRONT, SIDE, BACK }
 
var _status: int = _Status.INACTIVE
var _tank_pos: int = _Positions.LEFT
var _tank_facing: int = _Facings.FRONT
var _tank
var _tank_parent
var _arrow_parent
var _half_tank_height: int
var _half_tank_width: int
var _last_offset: float
var _max_x:int
var _min_x:int
var _want_to_move:bool
var _num_moves_done:int

func _input(event: InputEvent)->void:
	match _status:
		_Status.POSITIONING_ARROW:
			if event.is_action("ui_down"):
				unit_offset += VELOCITY
			elif event.is_action("ui_up"):
				unit_offset -= VELOCITY
			elif event.is_action_released("ui_cancel"):
				_want_to_move = false
				emit_signal("arrow_accepted")
			elif event.is_action_released("ui_accept"):
				emit_signal("arrow_accepted")
		_Status.POSITIONING_TANK:
			if event.is_action("ui_down"):
				_tank.position.x -= SHADOW_VELOCITY
				_adjust_tank_x_pos()
			elif event.is_action("ui_up"):
				_tank.position.x += SHADOW_VELOCITY
				_adjust_tank_x_pos()
			elif event.is_action_pressed("ui_left"):
				_change_tank_position()
			elif event.is_action_pressed("ui_right"):
				_change_tank_facing()
			elif event.is_action_released("ui_accept"):
				if not _tank.overlapping_tank_or_building:
					emit_signal("arrow_accepted")

func move(new_tank)-> void:
	_tank = new_tank
	_tank_parent = new_tank.get_parent()
	_arrow_parent = self.get_parent()
	var tank_size = new_tank.hull.get_rect().size
	_half_tank_height = tank_size.y/2
	_half_tank_width = tank_size.x/2
	_want_to_move = true
	_num_moves_done = 0
	while _want_to_move and _num_moves_done < 2:
		yield(_move_step(), "completed")
		_num_moves_done = _num_moves_done+1
		if _want_to_move:
			_tank.set_movement_token(_num_moves_done)
	_status = _Status.INACTIVE

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
	_status = _Status.POSITIONING_ARROW
	yield(self, "arrow_accepted")
	if _want_to_move:
		_status = _Status.POSITIONING_TANK
		_reparent_tank_under_arrow()
		yield(self, "arrow_accepted")
		_reparent_tank_over_arrow()

func _change_tank_facing() -> void:
	if _tank_facing == _Facings.BACK:
		_tank_facing = _Facings.FRONT
	else:
		_tank_facing += 1
	_place_tank()

func _change_tank_position() -> void:
	if _tank_pos == _Positions.LEFT:
		_tank_pos = _Positions.RIGHT
	else:
		_tank_pos = _Positions.LEFT
	_place_tank()

func _adjust_tank_x_pos()->void:
	_tank.position.x = clamp(_tank.position.x, _min_x, _max_x)


func _place_tank() -> void:
	var _half_tank_dimension: int
	match _tank_facing:
		_Facings.FRONT:
			_tank.rotation = 0
			_half_tank_dimension = _half_tank_height
			_min_x = _half_tank_width
		_Facings.BACK:
			_tank.rotation = PI
			_half_tank_dimension = _half_tank_height
			_min_x = _half_tank_width
		_Facings.SIDE:
			if _tank_pos == _Positions.LEFT:
				_tank.rotation = -PI/2
			else:
				_tank.rotation = PI/2
			_half_tank_dimension = _half_tank_width
			_min_x = _half_tank_height
	
	match _tank_pos:
		_Positions.LEFT:
			_tank.position.y = -(HALF_ARROW_HEIGHT + _half_tank_dimension)
		_Positions.RIGHT:
			_tank.position.y = +(HALF_ARROW_HEIGHT + _half_tank_dimension)
	
	_max_x = ARROW_WIDTH - _min_x
	_adjust_tank_x_pos()