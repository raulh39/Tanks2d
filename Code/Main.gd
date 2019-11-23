extends Node2D

onready var _gui := $CanvasLayer/GUI
var _shooting:=false

func _ready():
	while true:
		$CanvasLayer/GUI.setPhase(Gui.Phases.MOVE)
		yield($TankList.move_tanks(), "completed")
		$CanvasLayer/GUI.setPhase(Gui.Phases.SHOOT)
		_shooting = true
		yield($TankList.shoot_with_tanks(), "completed")
		_shooting = false
		$CanvasLayer/GUI.setPhase(Gui.Phases.COMMAND)
		yield($TankList.command_tanks(), "completed")


func _on_TankList_mouse_entered_target_vehicle(vehicle):
	_gui.show_info()


func _on_TankList_mouse_exited_target_vehicle(vehicle):
	_gui.hide_info()


func _on_TankList_vehicle_shooted():
	_gui.hide_info()
