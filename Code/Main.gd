extends Node2D

onready var _gui := $CanvasLayer/GUI
onready var _tank_list := $TankList

func _ready():
	var _3d_viewport := $Viewport
	var _viewport_sprite := $CanvasLayer/Container3D/ViewportSprite
	_3d_viewport.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	# Let two frames pass to make sure the screen was captured
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	_viewport_sprite.texture = _3d_viewport.get_texture()
	
	while true:
		yield(_move(), "completed")
		yield(_shoot(), "completed")
		yield(_command(), "completed")

func _move() -> void:
		$CanvasLayer/GUI.setPhase(Gui.Phases.MOVE)
		_tank_list.reset_tanks()
		while _tank_list.more_to_act():
			yield(_tank_list.select_and_move_one_tank(), "completed")

func _shoot() -> void:
		$CanvasLayer/GUI.setPhase(Gui.Phases.SHOOT)
		_tank_list.reset_tanks()
		while _tank_list.more_to_act():
			var st:Vehicle = yield(_tank_list.select_tank_to_shoot(), "completed")
			_gui.update_shooter_info(st)
			
			Signals.connect("mouse_entered", _gui, "show_target_info")
			Signals.connect("mouse_exited", _gui, "hide_info")
			var tt:Vehicle = yield(_tank_list.select_target_tank(st), "completed")
			Signals.disconnect("mouse_entered", _gui, "show_target_info")
			Signals.disconnect("mouse_exited", _gui, "hide_info")
			
			yield(_roll(5), "completed") #TODO: change that 5
			yield(_roll(3), "completed") #TODO: change that 3
			_gui.hide_info(tt)

func _command() -> void:
	$CanvasLayer/GUI.setPhase(Gui.Phases.COMMAND)
	yield(_tank_list.command_tanks(), "completed")

func _roll(dice_number: int) -> void:
	$CanvasLayer/Container3D.visible = true
	$Viewport/Roll.roll(dice_number)
	yield($Viewport/Roll, "rolled")
	$CanvasLayer/Container3D.visible = false
