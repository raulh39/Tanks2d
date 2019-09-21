extends PathFollow2D

class_name Arrow

const VELOCITY := 0.01
const SHADOW_VELOCITY = 10

signal arrow_accepted

enum Status { INACTIVE, POSITIONING_ARROW, POSITIONING_TANK }

var status: int = Status.INACTIVE

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
				$ArrowSprite/TankShadowSprite.position.x += SHADOW_VELOCITY
			elif event.is_action("ui_up"):
				$ArrowSprite/TankShadowSprite.position.x -= SHADOW_VELOCITY
			elif event.is_action_released("ui_accept"):
				emit_signal("arrow_accepted")

func move(tank_shadow_sprite: Texture)-> void:
	$ArrowSprite/TankShadowSprite.texture = tank_shadow_sprite
	$ArrowSprite/TankShadowSprite.modulate = Color(1,1,1,.5)
	$ArrowSprite/TankShadowSprite.visible = false
	status = Status.POSITIONING_ARROW
	yield(self, "arrow_accepted")
	$ArrowSprite/TankShadowSprite.visible = true
	status = Status.POSITIONING_TANK
	yield(self, "arrow_accepted")
	status = Status.INACTIVE
	$ArrowSprite/TankShadowSprite.texture = null
	return $ArrowSprite/TankShadowSprite.position