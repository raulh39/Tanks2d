extends Node2D

func _ready()->void:
	var bg := $Dialog/Background as Sprite
	print("                 [Screen Metrics]")
	print("            Display size: ", OS.get_screen_size())
	print("   Decorated Window size: ", OS.get_real_window_size())
	print("             Window size: ", OS.get_window_size())
	print("        Project Settings: Width=", ProjectSettings.get_setting("display/window/size/width"), " Height=", ProjectSettings.get_setting("display/window/size/height")) 
	print(" Background texture size: ", bg.get_rect().size)
	print("        Background scale: ", bg.scale)
	$Dialog.position = (OS.window_size - bg.get_rect().size * bg.scale)/2

func _on_New_Game_pressed():
	get_tree().change_scene("res://Scenes/Main.tscn")

func _on_Quit_Game_pressed():
	$ConfirmationDialog.popup_centered()

func _on_ConfirmationDialog_confirmed():
	get_tree().quit()
