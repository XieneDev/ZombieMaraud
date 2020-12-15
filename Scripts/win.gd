extends Control


var can_restart := false


func _ready() -> void:
	set_process(false)


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if can_restart:
			# When a button is pressed and 2 seconds have elapsted already
			# Go back to Main Menu
			Globals.options_menu.select_sfx.play()
			get_tree().change_scene("res://Scenes/MainMenu.tscn")


func _on_Timer_timeout() -> void:
	# After 2 seconds it becomes possible to restart the game
	can_restart = true
