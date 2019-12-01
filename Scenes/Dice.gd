extends Sprite

var _rolling := false
var time_left_rolling : float

signal rolled(number)

func roll(time: float) -> void:
	time_left_rolling = time
	_rolling = true

func _process(delta: float) -> void:
	if not _rolling:
		return
	frame = randi() % 6
	time_left_rolling -= delta
	if time_left_rolling <= 0.0:
		_rolling = false
		emit_signal("rolled", frame+1)

func get_size() -> Vector2:
	return texture.get_size() / hframes
