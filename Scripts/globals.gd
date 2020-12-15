extends Node


var player : KinematicBody2D
var can_pause := true
var screenshake := true
onready var options_menu : Control = OptionsMenu.get_child(0)


func _ready() -> void:
	set_process(false)


func freeze(t: float) -> void:
	# Freeze game for 't' seconds
	get_tree().paused = true
	yield(get_tree().create_timer(t), "timeout")
	get_tree().paused = false
