extends RigidBody

class_name Dice

const MAX_ANGULAR_VELOCITY := 20
const MAX_LINEAR_VELOCITY := 20

onready var rc_1 := $rc_1
onready var rc_2 := $rc_2
onready var rc_3 := $rc_3
onready var rc_4 := $rc_4
onready var rc_5 := $rc_5
onready var rc_6 := $rc_6

func _ready():
	self.angular_velocity = Vector3(
									rand_range(-MAX_ANGULAR_VELOCITY, MAX_ANGULAR_VELOCITY),
									rand_range(-MAX_ANGULAR_VELOCITY, MAX_ANGULAR_VELOCITY),
									rand_range(-MAX_ANGULAR_VELOCITY, MAX_ANGULAR_VELOCITY)
							)
	self.linear_velocity = Vector3(
									rand_range(-MAX_LINEAR_VELOCITY, MAX_LINEAR_VELOCITY),
									rand_range(-MAX_LINEAR_VELOCITY, 0),
									rand_range(-MAX_LINEAR_VELOCITY, MAX_LINEAR_VELOCITY)
							)
	self.rotation_degrees = Vector3(
									rand_range(0, 360),
									rand_range(0, 360),
									rand_range(0, 360)
							)

func number_shown() -> int:
	if rc_1.is_colliding(): return 1
	if rc_2.is_colliding(): return 2
	if rc_3.is_colliding(): return 3
	if rc_4.is_colliding(): return 4
	if rc_5.is_colliding(): return 5
	if rc_6.is_colliding(): return 6
	return 0
