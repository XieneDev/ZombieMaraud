extends KinematicBody2D


var SPD := 250  # Speed of the bullet. Unit is pixels per second

var angle_vector : Vector2  # A unit vector corresponding to the direction. This is set by player.gd


func _ready() -> void:
	set_process(false)


func _physics_process(_delta: float) -> void:
	move_and_slide(angle_vector * SPD)
	
	# If it detects a wall, delete itself
	if get_slide_count() > 0:
		queue_free()
