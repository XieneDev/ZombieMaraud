extends KinematicBody2D
class_name Zombie


var SPD := 50  # How fast the zombie moves towards the player. Unit is pixels per second
var ACC := 400  # How fast the zombie accelerates. Unit is pixels per second per second

var knockback := 150  # The knockback speed from bullets. Unit is pixels per second

var health := 3  # How many hit the zombie can take before dying


var area : int
var velocity := Vector2.ZERO


onready var game := get_tree().current_scene


func _physics_process(delta: float) -> void:
	# Check if this zombie is in the same area as the player
	if area == Globals.player.area:
		
		# Find the direction to the player in (unit) vector form
		var to_player := (Globals.player.position - position).normalized()
		# Move towards the player
		velocity = velocity.move_toward(to_player * SPD, ACC * delta)
		
		velocity = move_and_slide(velocity)
		
		
		if abs(Globals.player.position.x - position.x) > abs(Globals.player.position.y - position.y):
			# If the player is closer horizontally than vertically to the zombie
			
			$Sprite.frame = 2
			$Flash.frame = 1
			# Flip the sprite to look towards the player
			$Sprite.flip_h = Globals.player.position.x < position.x
			$Flash.flip_h = $Sprite.flip_h
		else:
			# If the player is closer vertically than horizontally to the zombie
			if Globals.player.position.y < position.y:
				# If the player is above the zombie
				$Sprite.frame = 5
				$Flash.frame = 2
			else:
				# If the zombie is above the player
				$Sprite.frame = 0
				$Flash.frame = 0


func die() -> void:
	# Create a coin and destroy itself
	var coin_ins = game.coin_obj.instance()
	coin_ins.position = position
	game.y_sort.call_deferred("add_child", coin_ins)
	game.enemy_count -= 1
	queue_free()


func _on_Area2D_body_entered(body: Node2D) -> void:
	# When a bullet enters the Area2D
	# Take knockback, delete the bullet, start flashing and play sfx
	velocity = body.angle_vector * knockback
	body.queue_free()
	$FlashAnimationPlayer.play("Flash")
	get_tree().current_scene.hurt_sfx.play()
	
	# Take 1 health away
	health -= 1
	Globals.freeze(0.033)
	if health <= 0:
		# If the health drops to 0, die
		die()
