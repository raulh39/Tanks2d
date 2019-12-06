extends RigidBody

class_name Dice

func _ready() -> void:
	stop()

func run() -> void:
	mode = MODE_RIGID

func stop() -> void:
	mode = MODE_STATIC
