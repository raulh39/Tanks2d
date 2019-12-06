extends Node2D

onready var _gui := $CanvasLayer/GUI

var _shooting:=false

func _ready():
	var _3d_viewport := $Viewport
	var _viewport_sprite := $CanvasLayer/Container3D/ViewportSprite
	_3d_viewport.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	# Let two frames pass to make sure the screen was captured
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	_viewport_sprite.texture = _3d_viewport.get_texture()
	
	while true:
		$CanvasLayer/GUI.setPhase(Gui.Phases.MOVE)
		yield($TankList.move_tanks(), "completed")
		$CanvasLayer/GUI.setPhase(Gui.Phases.SHOOT)
		_shooting = true
		yield($TankList.shoot_with_tanks(), "completed")
		_shooting = false
		$CanvasLayer/GUI.setPhase(Gui.Phases.COMMAND)
		yield($TankList.command_tanks(), "completed")

func _on_TankList_vehicle_about_to_shoot(shooting_tank):
	_gui.update_shooting_tank_info(shooting_tank)

func _on_TankList_mouse_entered_target_vehicle(target_tank: Vehicle)->void:
	_gui.show_info(target_tank)

func _on_TankList_mouse_exited_target_vehicle(target_tank: Vehicle)->void:
	_gui.hide_info()

func _on_TankList_vehicle_shooted():
	_gui.hide_info()
