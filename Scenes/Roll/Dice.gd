extends RigidBody

func _ready() -> void:
	add_to_group("dices")
	stop()

func run() -> void:
	mode = MODE_RIGID

func stop() -> void:
	mode = MODE_STATIC
