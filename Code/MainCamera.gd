extends Camera2D

func clamp_offset() -> void:
		offset.x = clamp(offset.x, -500, limit_right  - OS.window_size.x * zoom.x+500)
		offset.y = clamp(offset.y, -500, limit_bottom - OS.window_size.y * zoom.y+500)
#	if zoom.x < MAX_ZOOM_LEVEL:
#	else:
#		offset.x = 0
#		offset.y = 0

const MIN_ZOOM_LEVEL: float = 0.5
var MAX_ZOOM_LEVEL: float
const ZOOM_INCREMENT: float = 0.05

func _ready():
	MAX_ZOOM_LEVEL = (4500+500+500) / OS.window_size.y

var _drag: bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cam_drag"):
		_drag = true
	elif event.is_action_released("cam_drag"):
		_drag = false
	elif event.is_action("cam_zoom_in"):
		_update_zoom(-ZOOM_INCREMENT)
	elif event.is_action("cam_zoom_out"):
		_update_zoom(ZOOM_INCREMENT)
	elif event is InputEventMouseMotion && _drag:
		offset -= Vector2(event.relative.x*zoom.x, event.relative.y*zoom.y)
		clamp_offset()


func _update_zoom(incr: float) -> void:
	var new_zoom := Vector2(
		clamp(zoom.x+incr, MIN_ZOOM_LEVEL, MAX_ZOOM_LEVEL),
		clamp(zoom.y+incr, MIN_ZOOM_LEVEL, MAX_ZOOM_LEVEL)
	)
	if new_zoom == zoom:
		return
	
	var old_mp := get_local_mouse_position()
	zoom = new_zoom
	var new_mp := get_local_mouse_position()
	var diff := new_mp - old_mp
	offset -= diff
	clamp_offset()
