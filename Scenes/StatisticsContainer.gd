extends VBoxContainer

onready var _attack_dice_number := $AttackContainer/AttackDiceNumber
onready var _stationary := $StationaryContainer/StationaryCB
onready var _shooting_tank_mov_number := $ShootingTankMovContainer/ShootingTankMovNumber

onready var _defense_dice_number := $DefenseContainer/DefenseDiceNumber
onready var _defense_value_number := $DefenseValueContainer/DefenseValueNumber
onready var _target_tank_mov_number := $TargetTankMovContainer/TargetTankMovNumber
onready var _close_range := $CloseRangeContainer/CloseRangeCB
onready var _cover := $CoverContainer/CoverCB
onready var _side_shot := $SideShotContainer/SideShotCB

func update_shooting_info(shooting_tank: Vehicle) -> void:
	_attack_dice_number.text = str(shooting_tank.attack)
	_shooting_tank_mov_number.text = str(shooting_tank.movements)
	if shooting_tank.movements == 0:
		_stationary.pressed = true
		_stationary.text = "May reroll"
	else:
		_stationary.pressed = false
		_stationary.text = ""
	

func update_target_info(target_tank: Vehicle) -> void:
	print("A tank is a possible target: ", target_tank)
