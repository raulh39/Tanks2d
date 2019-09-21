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
			elif event.is_action_released("ui_accept"):
				emit_signal("arrow_accepted")

func move(new_tank)-> void:
	tank = new_tank
	yield(_move_step(), "completed")
	yield(_move_step(), "completed")
	status = Status.INACTIVE
	$ArrowSprite/TankShadowSprite.texture = null

func _move_step() -> void:
	$ArrowSprite/TankShadowSprite.visible = false
	status = Status.POSITIONING_ARROW
	yield(self, "arrow_accepted")
	$ArrowSprite/TankShadowSprite.texture = tank.ghost_shape
	$ArrowSprite/TankShadowSprite.modulate = Color(1,1,1,.5)
	$ArrowSprite/TankShadowSprite.visible = true
	status = Status.POSITIONING_TANK
	yield(self, "arrow_accepted")
	tank.global_position = $ArrowSprite/TankShadowSprite.global_position
	tank.global_rotation = $ArrowSprite/TankShadowSprite.global_rotation

func _place_ghost(new_ghost_position: int) -> void:
	var half_tank_height = tank.ghost_shape.get_height()/2
	var half_tank_width = tank.ghost_shape.get_width()/2
	$ArrowSprite/TankShadowSprite.position.y = -(half_arrow_height + half_tank_height)
