extends Control


onready var resume_button := $VBoxContainer/Resume
onready var options_button := $VBoxContainer/Options


func _ready() -> void:
	# Hide this when loading the game
	visible = false
	set_process(false)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_pause"):
		# Unpause the game
		Globals.options_menu.leave()
		leave()


func start() -> void:
	# Open the Pause Menu
	visible = true
	resume_button.grab_focus()
	Globals.options_menu.select_sfx.play()
	set_process(true)


func leave() -> void:
	# Unpause the game
	visible = false
	get_tree().paused = false
	set_process(false)


func leave_options() -> void:
	# Called when leaving the options menu
	$VBoxContainer.visible = true
	options_button.grab_focus()
	Globals.options_menu.disconnect("leave", self, "leave_options")


func _on_Resume_pressed() -> void:
	# Unpause the game
	leave()
	Globals.options_menu.select_sfx.play()


func _on_Options_pressed() -> void:
	# Open the options menu
	$VBoxContainer.visible = false
	Globals.options_menu.start()
	# Make sure 'leave_options' gets called when leaving the options menu
	Globals.options_menu.connect("leave", self, "leave_options")
	Globals.options_menu.select_sfx.play()


func _on_Quit_pressed() -> void:
	get_tree().quit()
