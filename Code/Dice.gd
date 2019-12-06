extends RigidBody

class_name Dice

const MAX_ANGULAR_VELOCITY := 20
const MAX_LINEAR_VELOCITY := 20

func _ready():
	self.angular_velocity = Vector3(
									rand_range(-MAX_ANGULAR_VELOCITY, MAX_ANGULAR_VELOCITY),
									rand_range(-MAX_ANGULAR_VELOCITY, MAX_ANGULAR_VELOCITY),
									rand_range(-MAX_ANGULAR_VELOCITY, MAX_ANGULAR_VELOCITY)
							)
	self.linear_velocity = Vector3(
									rand_range(-MAX_LINEAR_VELOCITY, MAX_LINEAR_VELOCITY),
									rand_range(-MAX_LINEAR_VELOCITY, MAX_LINEAR_VELOCITY),
									rand_range(-MAX_LINEAR_VELOCITY, MAX_LINEAR_VELOCITY)
							)
	self.rotation_degrees = Vector3(
									rand_range(0, 360),
									rand_range(0, 360),
									rand_range(0, 360)
							)
	