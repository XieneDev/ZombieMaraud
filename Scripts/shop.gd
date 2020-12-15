extends StaticBody2D


# All upgrades you can buy
var upgrades = [{"name": "Faster Movement", "info": "Increases your movement speed by 20%", "cost": 8, "infinite": false},
{"name": "Faster Shotting", "info": "Reduces the cooldown on shooting", "cost": 10, "infinite": false},
{"name": "Less Knockback", "info": "Reduces the knockback you take when shooting", "cost": 6, "infinite": false},
{"name": "Heal 1 heart", "info": "Heals 1 heart. Can be bought as many times as you want", "cost": 5, "infinite": true},]


var upgrade_buttons = []  # Array of all buttons corresponding to upgrades
var bought = []  # Array of upgrades that have already been bought
onready var menu := $CanvasLayer/Control


func _ready() -> void:
	# When loaded, hide this
	menu.visible = false
	set_process(false)
	
	for i in range(0, len(upgrades)):
		# Create a button for every upgrade
		var button_ins := Button.new()
		button_ins.text = upgrades[i].name
		button_ins.size_flags_vertical = Control.SIZE_EXPAND_FILL
		$CanvasLayer/Control/ToBuy.add_child(button_ins)
		# Connect all buttons to several functions in this script
		button_ins.connect("mouse_entered", self, "button_focused", [i])
		button_ins.connect("focus_entered", self, "button_focused", [i])
		button_ins.connect("pressed", self, "button_pressed", [i])
		# Add the new button to the 'upgrade_buttons' array
		upgrade_buttons.append(button_ins)
		bought.append(false)


func _process(_delta: float) -> void:
	# Pressing a pause button will exit the shop
	if Input.is_action_just_pressed("ui_pause"):
		leave()


func start() -> void:
	# Called when the player opens the shop
	# Show this, prevent the player from pausing and pause the game world
	get_tree().paused = true
	Globals.can_pause = false
	menu.visible = true
	upgrade_buttons[0].grab_focus()
	set_process(true)


func leave() -> void:
	# Called when the player leaves the shop menu
	# Hide this, let the player pause again and resume the game world
	get_tree().paused = false
	Globals.can_pause = true
	menu.visible = false
	set_process(false)


func button_pressed(i: int) -> void:
	# Called when an upgrade button is pressed
	var upgrade = upgrades[i]
	if Globals.player.coins >= upgrade.cost and not bought[i]:
		# Apply the corresponding effect for the upgrade
		match i:
			0: # Faster Movement
				Globals.player.SPD *= 1.2
			1: # Faster Shooter
				Globals.player.shoot_time = 0.3
			2: # Less knockback
				Globals.player.shoot_knockback *= 0.6
			3: # Heal
				Globals.player.health = min(Globals.player.health+1, Globals.player.max_health)
		
		Globals.player.coins -= upgrades[i].cost
		if not upgrade.infinite:
			$CanvasLayer/Control/ToBuy.remove_child(upgrade_buttons[i])
			$CanvasLayer/Control/Bought.add_child(upgrade_buttons[i])
			upgrade_buttons[i].set_owner($CanvasLayer/Control/Bought)
			bought[i] = true
			upgrade_buttons[i].grab_focus()
		Globals.options_menu.select_sfx.play()


func button_focused(i: int) -> void:
	# Show the description of the selected upgrade
	$CanvasLayer/Control/Info.text = upgrades[i].info
	$CanvasLayer/Control/Cost.text = "Cost: " + str(upgrades[i].cost) + (" (BOUGHT)" if bought[i] else "")


func _on_Back_pressed() -> void:
	leave()



func _on_Area2D_body_entered(body: Node2D) -> void:
	if body is Player:
		body.shop = self


func _on_Area2D_body_exited(body: Node2D) -> void:
	if body is Player:
		body.shop = null
