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
var tank
var half_tank_height: int
var half_tank_width: int

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
				$ArrowSprite/TankShadowSprite.position.x -= SHADOW_VELOCITY
			elif event.is_action("ui_up"):
				$ArrowSprite/TankShadowSprite.position.x += SHADOW_VELOCITY
			elif event.is_action_pressed("ui_left"):
				_change_ghost_position()
			elif event.is_action_pressed("ui_right"):
				_change_ghost_facing()
			elif event.is_action_released("ui_accept"):
				emit_signal("arrow_accepted")

func move(new_tank)-> void:
	tank = new_tank
	$ArrowSprite/TankShadowSprite.texture = tank.ghost_shape
	#$ArrowSprite/TankShadowSprite.modulate = Color(1,1,1,.75)
	half_tank_height = tank.ghost_shape.get_height()/2
	half_tank_width = tank.ghost_shape.get_width()/2
	_place_ghost()
	yield(_move_step(), "completed")
	yield(_move_step(), "completed")
	status = Status.INACTIVE
	$ArrowSprite/TankShadowSprite.texture = null

func _move_step() -> void:
	status = Status.POSITIONING_ARROW
	$ArrowSprite/TankShadowSprite.visible = false
	yield(self, "arrow_accepted")
	status = Status.POSITIONING_TANK
	$ArrowSprite/TankShadowSprite.visible = true
	tank.hull.visible = false
	yield(self, "arrow_accepted")
	tank.hull.visible = true
	tank.global_position = $ArrowSprite/TankShadowSprite.global_position
	tank.global_rotation = $ArrowSprite/TankShadowSprite.global_rotation

func _change_ghost_facing() -> void:
	if ghost_facing == Facings.BACK:
		ghost_facing = Facings.FRONT
	else:
		ghost_facing += 1
	_place_ghost()

func _change_ghost_position() -> void:
	if ghost_position == Positions.LEFT:
		ghost_position = Positions.RIGHT
	else:
		ghost_position = Positions.LEFT
	_place_ghost()

func _place_ghost() -> void:
	var half_tank_dimension: int
	match ghost_facing:
		Facings.FRONT:
			$ArrowSprite/TankShadowSprite.rotation = 0
			half_tank_dimension = half_tank_height
		Facings.BACK:
			$ArrowSprite/TankShadowSprite.rotation = PI
			half_tank_dimension = half_tank_height
		Facings.SIDE:
			if ghost_position == Positions.LEFT:
				$ArrowSprite/TankShadowSprite.rotation = -PI/2
			else:
				$ArrowSprite/TankShadowSprite.rotation = PI/2
			half_tank_dimension = half_tank_width
	
	match ghost_position:
		Positions.LEFT:
			$ArrowSprite/TankShadowSprite.position.y = -(half_arrow_height + half_tank_dimension)
		Positions.RIGHT:
			$ArrowSprite/TankShadowSprite.position.y = +(half_arrow_height + half_tank_dimension)
