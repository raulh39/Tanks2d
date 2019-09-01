extends Camera2D

const MIN_ZOOM_LEVEL: float = 0.5
const MAX_ZOOM_LEVEL: float = 4.17
const ZOOM_INCREMENT: float = 0.05

#Errors in this code:
#   - doesn't zoom centering at mouse position

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
		var new_offset := offset - Vector2(event.relative.x*zoom.x, event.relative.y*zoom.y)
		new_offset.x = clamp(new_offset.x, limit_left, limit_right-OS.window_size.x*zoom.x)
		new_offset.y = clamp(new_offset.y, limit_top, limit_bottom-OS.window_size.y*zoom.y)
		offset = new_offset


func _update_zoom(incr: float) -> void:
	var new_zoom := Vector2(
		clamp(zoom.x+incr, MIN_ZOOM_LEVEL, MAX_ZOOM_LEVEL),
		clamp(zoom.y+incr, MIN_ZOOM_LEVEL, MAX_ZOOM_LEVEL)
	)
	if new_zoom == zoom:
		return
	
	offset = get_local_mouse_position()
	zoom = new_zoom
	print("New zoom: " + str(zoom))
	# var zoom_center = mouse_position - offset
	# var ratio = 1-_current_zoom_level____________/old_zoom
	# offset = offset + zoom_center*ratio
