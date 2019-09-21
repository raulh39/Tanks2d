extends PathFollow2D

class_name Arrow

const VELOCITY := 0.01
const SHADOW_VELOCITY = 10

signal arrow_accepted

enum Status { INACTIVE, POSITIONING_ARROW, POSITIONING_TANK }

enum Positions { STRAIGHT_LEFT, STRAIGHT_RIGHT, ROTATED_LEFT, ROTATED_RIGHT}

var status: int = Status.INACTIVE
var ghost_position: int = Positions.STRAIGHT_LEFT

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
				_change_ghost_position(+1)
			elif event.is_action_pressed("ui_right"):
				_change_ghost_position(-1)
			elif event.is_action_released("ui_accept"):
				emit_signal("arrow_accepted")

func move(new_tank)-> void:
	tank = new_tank
	$ArrowSprite/TankShadowSprite.texture = tank.ghost_shape
	$ArrowSprite/TankShadowSprite.modulate = Color(1,1,1,.5)
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
	yield(self, "arrow_accepted")
	tank.global_position = $ArrowSprite/TankShadowSprite.global_position
	tank.global_rotation = $ArrowSprite/TankShadowSprite.global_rotation

func _change_ghost_position(inc: int) -> void:
	ghost_position += inc
	if ghost_position < Positions.STRAIGHT_LEFT:
		ghost_position = Positions.ROTATED_RIGHT
	elif ghost_position > Positions.ROTATED_RIGHT:
		ghost_position = Positions.STRAIGHT_LEFT
	_place_ghost()

func _place_ghost() -> void:
	match ghost_position:
		Positions.STRAIGHT_LEFT:
			$ArrowSprite/TankShadowSprite.rotation = 0
			$ArrowSprite/TankShadowSprite.position.y = -(half_arrow_height + half_tank_height)
		Positions.STRAIGHT_RIGHT:
			$ArrowSprite/TankShadowSprite.rotation = 0
			$ArrowSprite/TankShadowSprite.position.y = +(half_arrow_height + half_tank_height)
		Positions.ROTATED_LEFT:
			$ArrowSprite/TankShadowSprite.rotation = +PI/2
			$ArrowSprite/TankShadowSprite.position.y = 0
		Positions.ROTATED_RIGHT:
			$ArrowSprite/TankShadowSprite.rotation = -PI/2
			$ArrowSprite/TankShadowSprite.position.y = 0
