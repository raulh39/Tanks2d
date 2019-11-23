extends VBoxContainer

func update_shooting_info(shooting_tank: Vehicle) -> void:
	print("A tank is shooting: ", shooting_tank)

func update_target_info(target_tank: Vehicle) -> void:
	print("A tank is a possible target: ", target_tank)
