extends Control


onready var restart_button := $VBoxContainer/Restart


onready var game := get_tree().current_scene


func _ready() -> void:
	# Hide this when the gameplay scene is loaded
	visible = false
	set_process(false)


func start() -> void:
	# Called when the game over menu is opened
	visible = true
	restart_button.grab_focus()


func _on_Restart_pressed() -> void:
	# Restart the game
	visible = false
	game.restart()
	get_tree().paused = false


func _on_MainMenu_pressed() -> void:
	# Go back to the main menu
	get_tree().change_scene("res://Scenes/MainMenu.tscn")
	get_tree().paused = false


func _on_Quit_pressed() -> void:
	get_tree().quit()
