extends Node2D
class_name Coin


var time := 0.0


onready var origin := position.y


func _process(delta: float) -> void:
	time += delta
	position.y = origin + cos(time*4)*4  # Move in a cosine wave


func _on_Area2D_body_entered(body: Node2D) -> void:
	if body is Player:
		# When the player enters the hitbox, increment coin count and delete itself
		Globals.player.coins += 1
		get_tree().current_scene.coin_sfx.play()
		queue_free()
