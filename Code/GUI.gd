extends MarginContainer

class_name Gui

enum Phases { MOVE, SHOOT, COMMAND }

onready var _phase_label: Label = ($CenterContainer/MainContainer/Phase as Label)

func setPhase(new_phase: int) -> void:
	match new_phase:
		Phases.MOVE:
			_phase_label.text = "Movement Phase"
		Phases.SHOOT:
			_phase_label.text = "Shooting Phase"
		Phases.COMMAND:
			_phase_label.text = "Command Phase"
