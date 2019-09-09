extends Node2D

func _ready():
	$CanvasLayer/GUI.setPhase(Gui.Phases.MOVE)
	while true:
		yield($TankList.move_tanks(), "completed")
		#yield($TankList.shoot_with_tanks(), "completed")
		#yield($TankList.command_tanks(), "completed")
		print("Turn ended")
