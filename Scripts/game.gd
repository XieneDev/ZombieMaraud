extends Node2D


var wave := -1  # Current wave
var waves = {0: {"time": 1, "enemies": 10},
1: {"time": 0.5, "enemies": 10},
2: {"time": 0.5, "enemies": 20},
3: {"time": 0.3, "enemies": 20}}

var areas = [{"x": -496, "y": -40, "w": 288, "h": 248},
{"x": 16, "y": -40, "w": 352, "h": 248},
{"x": 608, "y": -40, "w": 256, "h": 248}]
var total_area : int

var enemy_count := 0 setget set_enemy_count
var enemies_spawned := 0

var dead := false


onready var y_sort := $YSort
onready var hide_planes = [$ColorRect2, $ColorRect3, $ColorRect4]
onready var pause_menu := PauseMenu.get_child(0)
onready var coin_sfx := $CoinSFX
onready var hurt_sfx := $HurtSFX


onready var zombie_obj := preload("res://Objects/Zombie.tscn")
onready var zombie_spawn_obj := preload("res://Objects/ZombieSpawn.tscn")
onready var coin_obj := preload("res://Objects/Coin.tscn")


func _ready() -> void:
	# Find in which area the player is
	for i in range(0, len(areas)):
		var area = areas[i]
		total_area += area.w * area.h
		
		# We don't need to check for the y coordinate because the areas can be determined just by x coordinate
		if Globals.player.position.x > area.x and Globals.player.position.x < area.x + area.w:
			Globals.player.area = i
	
	Globals.player.connect("die", self, "die")
	$CanvasLayer/Round.visible = true
	
	Globals.can_pause = true


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_pause") and Globals.can_pause:
		# Pause the game
		get_tree().paused = not get_tree().paused
		pause_menu.start()


func restart() -> void:
	# Restart all properties of the game to their initial state, so as not to reload the scene
	enemy_count = 0
	enemies_spawned = 0
	Globals.player.restart()
	# Remove all zombies and coins from the scene
	for i in range(0, y_sort.get_child_count()):
		var child = y_sort.get_child(i)
		
		if child is Zombie or child is Coin:
			child.queue_free()
	Globals.can_pause = true
	# Restart the waves
	wave = -1
	$WaveRestTimer.start()
	dead = false
	# Stop the music from playing when the game world is paused again
	$Music.pause_mode = Node.PAUSE_MODE_INHERIT


func die() -> void:
	# Called immediately after being hit by a zombie and falling to 0 hearts
	dead = true
	# Start a timer that will later pause the game world and bring up the death screen
	$DeadTimer.start()
	# Stop spawning new zombies
	$SpawnTimer.stop()
	Globals.can_pause = false
	# Let the music continue playing while the game world is paused
	$Music.pause_mode = Node.PAUSE_MODE_PROCESS


func _on_DeadTimer_timeout() -> void:
	# Called 0.8 seconds after taking the final hit
	get_tree().paused = true
	$GameOver/Control.start()


func start_wave() -> void:
	if wave >= len(waves):
		# If the 'waves' dictionary is exhausted, go to win screen
		win()
		return
	
	enemies_spawned = 0
	$SpawnTimer.wait_time = waves[wave].time
	$SpawnTimer.start()
	$CanvasLayer/Round/RoundLabel.text = "Round " + str(wave+1)
	$AnimationPlayer.play("Round")


func _on_SpawnTimer_timeout() -> void:
	# Spawn another zombie
	
	enemies_spawned += 1
	enemy_count += 1
	
	# Create the zombie object
	var zombie_spawn_ins := zombie_spawn_obj.instance()
	var pos = random_pos()
	zombie_spawn_ins.area = pos[0]
	zombie_spawn_ins.position = pos[1]
	y_sort.add_child(zombie_spawn_ins)
	
	# After spawning enough zombies, stop
	if enemies_spawned >= waves[wave].enemies:
		$SpawnTimer.stop()


func spawn_zombie(area: int, position: Vector2) -> void:
	# Create a zombie spawn warning at a random position
	var zombie_ins := zombie_obj.instance()
	zombie_ins.area = area
	zombie_ins.position = position
	y_sort.add_child(zombie_ins)


func random_pos():
	# Get a random position based on the 'areas' dictionary
	
	var rand = randf()
	
	var running_area := 0.0
	for i in range(0, len(areas)):
		var area = areas[i]
		running_area += area.w * area.h
		if rand <= running_area / total_area:
			return [i, Vector2(randi()%area.w + area.x, randi()%area.h + area.y)]



func set_enemy_count(new_enemy_count: int) -> void:
	enemy_count = new_enemy_count
	
	# After killing hte last zombie of the round, get ready for the next round
	if enemy_count == 0:
		$WaveRestTimer.start()


func _on_WaveRestTimer_timeout() -> void:
	# After getting ready for the new round, start it
	wave += 1
	start_wave()


func win() -> void:
	# Called after the last zombie of the last wave is killed
	Globals.can_pause = false
	$AnimationPlayer.play("FadeOut")


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "FadeOut":
		get_tree().change_scene("res://Scenes/Win.tscn")
