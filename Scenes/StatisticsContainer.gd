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
	var total_defense_dice :int = _shooting_tank_mov_number.text.to_int()
	
	_defense_value_number.text = str(target_tank.defense)
	total_defense_dice += target_tank.defense
	
	_target_tank_mov_number.text = str(target_tank.movements)
	total_defense_dice += target_tank.movements
	
	_close_range.pressed = false #TODO
	_close_range.text = "not implemented" #TODO
	
	if target_tank.visibility_status == Vehicle.TargetStatus.InCover:
		_cover.pressed = true
		_cover.text = "+1"
		total_defense_dice += 1
	else:
		_cover.pressed = false
		_cover.text = ""
	
	_side_shot.pressed = false #TODO
	_side_shot.text = "not implemented" #TODO
	
	_defense_dice_number.text = str(total_defense_dice)
