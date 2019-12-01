extends Node2D

onready var roll_button := $Roll
onready var add_button := $AddButton
onready var del_button := $DelButton

export (float, 0, 10) var rolling_time = 1.0
export (float,0,10) var dice_margin = 2
export (int,1,10) var max_number_of_dices = 5

var _dice_scene := preload("res://Scenes/Dice.tscn")
var _child_dices := []
var _next_child_position_x :float
var _numbers_rolled := []

func _ready():
	_next_child_position_x = $FirstDice.position.x
	_add_dice($FirstDice)

func _add_dice(new_dice: Sprite) -> void:
	_child_dices.append(new_dice)
	new_dice.connect("rolled", self, "_on_Rolled")
	_next_child_position_x += dice_margin + $FirstDice.get_size().x

func _on_AddButton_pressed():
	if _child_dices.size() == max_number_of_dices:
		return
	var new_dice := _dice_scene.instance()
	add_child(new_dice)
	new_dice.position = Vector2(_next_child_position_x, $FirstDice.position.y)
	_add_dice(new_dice)
	
func _on_DelButton_pressed():
	if _child_dices.size() == 1:
		return
	var old_dice: Node = _child_dices.pop_back()
	_next_child_position_x = old_dice.position.x
	remove_child(old_dice)
	old_dice.disconnect("rolled", self, "_on_Rolled")
	old_dice.queue_free()

func _on_Roll_pressed():
	_enable_buttons(false)
	_numbers_rolled = []
	for dice in _child_dices:
		dice.roll(rolling_time)

func _on_Rolled(number: int) -> void:
	_numbers_rolled.append(number)
	if _numbers_rolled.size() < _child_dices.size():
		return
	print(_numbers_rolled)
	_enable_buttons(true)

func _enable_buttons(enabled: bool) -> void:
	roll_button.disabled = not enabled
	add_button.disabled = not enabled
	del_button.disabled = not enabled
