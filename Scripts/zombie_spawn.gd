extends Node2D
class_name ZombieSpawn


var area : int  # Which of the 3 areas this is. Assigned when created by 'game.gd'


onready var game := get_tree().current_scene


func _ready() -> void:
	set_process(false)


func _on_Timer_timeout() -> void:
	# After the timer runs out, replace this with a zombie
	game.spawn_zombie(area, position)
	queue_free()
