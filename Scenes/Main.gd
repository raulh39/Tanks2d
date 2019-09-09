extends Node2D

func _ready():
	while true:
		$CanvasLayer/GUI.setPhase(Gui.Phases.MOVE)
		yield($TankList.move_tanks(), "completed")
		$CanvasLayer/GUI.setPhase(Gui.Phases.SHOOT)
		yield($TankList.shoot_with_tanks(), "completed")
		$CanvasLayer/GUI.setPhase(Gui.Phases.COMMAND)
		yield($TankList.command_tanks(), "completed")
		print("Turn ended")
