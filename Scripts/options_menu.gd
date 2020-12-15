extends Control


onready var fullscreen_button := $VBoxContainer/Fullscreen
onready var screenshake_button := $VBoxContainer/Screenshake
onready var select_sfx := $SelectSFX


signal leave


func _ready() -> void:
	# Hide this when loading the game
	visible = false
	set_process(false)


func start() -> void:
	# Called when the options menu is opened
	visible = true
	fullscreen_button.grab_focus()


func leave() -> void:
	# Leave the options menu
	visible = false
	emit_signal("leave")


func _on_Fullscreen_pressed() -> void:
	# Toggle fullscreen
	fullscreen_button.text = "Fullscreen: Off" if OS.window_fullscreen else "Fullscreen: On"
	OS.window_fullscreen = !OS.window_fullscreen
	select_sfx.play()


func _on_Screenshake_pressed() -> void:
	# Toggle screenshake
	Globals.screenshake = not Globals.screenshake
	screenshake_button.text = "Screenshake: On" if Globals.screenshake else "Screenshake: Off"
	select_sfx.play()


func _on_Back_pressed() -> void:
	# Leave the options menu
	leave()
	select_sfx.play()
