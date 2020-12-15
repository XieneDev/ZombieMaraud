extends Control


onready var play_button := $Control/VBoxContainer/Play
onready var options_button := $Control/VBoxContainer/Options


func _ready() -> void:
	play_button.grab_focus()
	set_process(false)


func leave_options() -> void:
	# Called when leaving the options menu
	$Control.visible = true
	options_button.grab_focus()
	Globals.options_menu.disconnect("leave", self, "leave_options")


func _on_Play_pressed() -> void:
	# Start the fade out that will lead to gameplay
	$AnimationPlayer.play("FadeOut")
	Globals.options_menu.select_sfx.play()


func _on_Options_pressed() -> void:
	# Open the options menu
	$Control.visible = false
	Globals.options_menu.start()
	# Make sure 'leave_options' gets called when leaving the options menu
	Globals.options_menu.connect("leave", self, "leave_options")
	Globals.options_menu.select_sfx.play()


func _on_Quit_pressed() -> void:
	get_tree().quit()


func _on_YTButton_pressed() -> void:
	# Open YouTube channel on a browser
	OS.shell_open("https://www.youtube.com/channel/UC5ZQIuHGBrYmnSwtgTBHgxA")
	Globals.options_menu.select_sfx.play()


func _on_ItchButton_pressed() -> void:
	# Open Itch.io profile on a browser
	OS.shell_open("https://xienedev.itch.io/")
	Globals.options_menu.select_sfx.play()


func _on_TwitterButton_pressed() -> void:
	# Open Twitter profile on a browser
	OS.shell_open("https://twitter.com/XieneDev")
	Globals.options_menu.select_sfx.play()


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "FadeOut":
		# After fade out is over, transition to gameplay
		get_tree().change_scene("res://Scenes/Node2D.tscn")
