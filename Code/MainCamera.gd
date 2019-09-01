extends Camera2D

const MAX_ZOOM_LEVEL: float = 0.5
const MIN_ZOOM_LEVEL: float = 4.18
const ZOOM_INCREMENT: float = 0.05

onready var _current_zoom_level: float = self.zoom.x
var _drag: bool = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cam_drag"):
		_drag = true
	elif event.is_action_released("cam_drag"):
		_drag = false
	elif event.is_action("cam_zoom_in"):
		_update_zoom(-ZOOM_INCREMENT, get_local_mouse_position())
	elif event.is_action("cam_zoom_out"):
		_update_zoom(ZOOM_INCREMENT, get_local_mouse_position())
	elif event is InputEventMouseMotion && _drag:
		var new_offset = get_offset() - event.relative*_current_zoom_level
		set_offset(new_offset)
		print(new_offset)


func _update_zoom(incr: float, zoom_anchor: Vector2) -> void:
	var old_zoom = _current_zoom_level
	_current_zoom_level += incr
	if _current_zoom_level < MAX_ZOOM_LEVEL:
		_current_zoom_level = MAX_ZOOM_LEVEL
	elif _current_zoom_level > MIN_ZOOM_LEVEL:
		_current_zoom_level = MIN_ZOOM_LEVEL
	if old_zoom == _current_zoom_level:
		return
		
	var zoom_center = zoom_anchor - get_offset()
	var ratio = 1-_current_zoom_level/old_zoom
	set_offset(get_offset() + zoom_center*ratio)
		
	set_zoom(Vector2(_current_zoom_level, _current_zoom_level))
