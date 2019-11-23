extends MarginContainer

class_name Gui

enum Phases { MOVE, SHOOT, COMMAND }

onready var _phase_label := $MainContainer/Phase
onready var _container := $MainContainer/StatisticsContainer
onready var _min_y_rect_size := rect_size.y

func setPhase(new_phase: int) -> void:
	match new_phase:
		Phases.MOVE:
			_phase_label.text = "Movement Phase"
		Phases.SHOOT:
			_phase_label.text = "Shooting Phase"
		Phases.COMMAND:
			_phase_label.text = "Command Phase"

func update_shooting_tank_info(shooting_tank: Vehicle) -> void:
	_container.update_shooting_info(shooting_tank)

func show_info(target_tank: Vehicle)->void:
	_container.update_target_info(target_tank)
	_container.visible = true

func hide_info():
	_container.visible = false
	rect_size.y = _min_y_rect_size
