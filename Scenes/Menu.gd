extends Node2D

func _on_New_Game_pressed():
	get_tree().change_scene("res://Scenes/Main.tscn")

func _on_Quit_Game_pressed():
	get_tree().quit()