extends KinematicBody2D
class_name Player


var SPD := 100  # Max speed for each axis. Unit is pixels per second
var ACC := 400  # Acceleration. Unit is pixels per second per second

var shoot_knockback := 100  # Knockback speed when shooting. Unit is pixels per second
var damage_knockback := 200  # Knockback speed when taking damage. Unit is pixels per second

var shoot_time := 0.5  # Delay between being able to shoot. Unit is seconds
var shoot_timer : float = 0

var inv_time := 0.8  # Invincibility time after being hit. Unit is seconds
var inv_timer : float = 0


var health := 3 setget set_health  # Max health for the player
var coins := 0 setget set_coins  # Number of coins the player has


var velocity := Vector2.ZERO
var area : int
var shop : Node2D setget set_shop
var max_health := health


onready var game := get_tree().current_scene
onready var original_pos := position
onready var original_spd := SPD
onready var original_shoot_time := shoot_time
onready var original_knockback := shoot_knockback
onready var anim_player := $AnimationPlayer
onready var anim_tree := $AnimationTree
onready var anim_state : AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")
onready var hurt_sfx := $HurtSFX
onready var shoot_sfx := $ShootSFX


onready var bullet_obj := preload("res://Objects/Bullet.tscn")


signal die


func _ready() -> void:
	Globals.player = self
	set_process(false)


func _physics_process(delta: float) -> void:
	move(delta)
	
	gun(delta)
	
	if Input.is_action_just_pressed("ui_action") and shop:
		# Open the shop UI
		shop.start()
	
	inv_timer -= delta
	
	# Change the current area of the player. If you are on a corridor, your area is -1.
	# Only zombies in the same area as you will move
	area = -1
	for i in range(0, len(game.areas)):
		var game_area = game.areas[i]
		if position.x+8 > game_area.x and position.x-8 < game_area.x + game_area.w:
			area = i
			game.hide_planes[i].visible = false
		else:
			game.hide_planes[i].visible = true


func move(delta: float) -> void:
	# Move in the direction you press with acceleration
	var desired_x := 0.0
	var desired_y := 0.0
	
	if not game.dead:
		desired_x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		desired_y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	velocity = velocity.move_toward(Vector2(desired_x, desired_y) * SPD, ACC*delta)
	
	
	velocity = move_and_slide(velocity)
	
	
	# Animations
	if desired_x != 0:
		# Face in the correct direction
		$Sprite.flip_h = desired_x < 0
		$FlashSprite.flip_h = $Sprite.flip_h
	
	if velocity != Vector2.ZERO:
		# Start the movement animation
		anim_tree.set("parameters/Move/TimeScale/scale", 1.5 * max(abs(velocity.x), abs(velocity.y)) / SPD)
		anim_state.travel("Move")
	else:
		# Start the idle animation
		anim_state.travel("Idle")


func gun(delta: float) -> void:
	# Get direction (unit) vector to mouse
	var to_mouse = get_global_mouse_position() - position
	# Adjust player visuals
	$GunPivot.rotation = to_mouse.angle()
	$GunPivot/Sprite.flip_v = not ($GunPivot.rotation < PI/2 and $GunPivot.rotation > -PI/2)
	
	if Input.is_action_pressed("ui_shoot") and shoot_timer <= 0:
		# Set the shoot delay
		shoot_timer = shoot_time
		
		var to_mouse_normalized = to_mouse.normalized()
		
		# Create the bullet
		var bullet_ins := bullet_obj.instance()
		bullet_ins.position = position + to_mouse_normalized * 8
		bullet_ins.angle_vector = to_mouse_normalized
		bullet_ins.rotation = $GunPivot.rotation
		get_tree().current_scene.add_child(bullet_ins)
		$Camera2D.add_trauma(0.35)
		
		# Take knockback
		velocity = -to_mouse_normalized * shoot_knockback
		
		shoot_sfx.play()
	
	shoot_timer -= delta


func restart() -> void:
	# Called when the player chooses 'Restart' after dying
	# Resets all player properties (so as to avoid reloading the scene)
	self.health = max_health
	self.coins = 0
	position = original_pos
	SPD = original_spd
	shoot_time = original_shoot_time
	shoot_knockback = original_knockback
	velocity = Vector2.ZERO


func set_health(new_health: int) -> void:
	health = new_health
	
	if health <= 0:
		emit_signal("die")
	
	# Update the health UI
	for i in range(0, 3):
		$CanvasLayer/Control/HBoxContainer.get_child(i).modulate = Color(0.5, 0.5, 0.5, 1) if health <= i else Color(1, 1, 1, 1)


func set_coins(new_coins: int) -> void:
	coins = new_coins
	
	# Update the coin UI
	$CanvasLayer2/Control/Coins/Label.text = str(coins)


func set_shop(new_shop: Node2D) -> void:
	shop = new_shop
	
	# Make the 'Interact' UI visible/hidden
	$CanvasLayer/Control/Interact.visible = shop != null


func _on_Area2D_body_entered(body: Node2D) -> void:
	# Called when a zombie hits the player
	
	if inv_timer < 0:
		# Set the invinsibility time
		inv_timer = inv_time
		
		# Take damage, knockback and start flashing
		velocity = damage_knockback * (position - body.position).normalized()
		$FlashAnimationPlayer.play("Flash")
		self.health -= 1
		
		# Screenshake, freeze time and SFX
		$Camera2D.add_trauma(1)
		Globals.freeze(0.05)
		hurt_sfx.play()

