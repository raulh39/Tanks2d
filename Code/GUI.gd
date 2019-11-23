extends MarginContainer

class_name Gui

enum Phases { MOVE, SHOOT, COMMAND }

onready var _phase_label: Label = ($MainContainer/Phase as Label)
onready var _min_y_rect_size := rect_size.y

func setPhase(new_phase: int) -> void:
	match new_phase:
		Phases.MOVE:
			_phase_label.text = "Movement Phase"
		Phases.SHOOT:
			_phase_label.text = "Shooting Phase"
		Phases.COMMAND:
			_phase_label.text = "Command Phase"


func _input(event):
	if event.is_action_released("toggle"):
		$MainContainer/StatisticsContainer.visible = not $MainContainer/StatisticsContainer.visible
		rect_size.y = _min_y_rect_size
