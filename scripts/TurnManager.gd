extends Node

@onready var battle_log = $"../Control/Panel/BattleLog"

enum TurnState { PLAYER_TURN, ENEMY_TURN }

var current_turn = TurnState.PLAYER_TURN
var player : CharacterBody2D
var enemies : Node
var startBattle : bool = false
var turn_queue = []
var initial_turn_order = []
var alive_characters = []
var mobs = []

func _ready():
	# Initialize player and enemies
	player = $"../main_char"
	enemies = $"../enemies"

func start_battle():
	if not startBattle:
		startBattle = true
		await get_tree().create_timer(2).timeout
		mobs.append_array(enemies.get_children())
		
		if(player.has_signal("on_dead")):
				player.on_dead.connect(_on_player_died.bind())
		
		# Connect the died signal for each mob
		for mob in mobs:
			if(mob.has_signal("on_dead")):
				mob.on_dead.connect(_on_mob_died.bind(mob))
		determine_turn_order()
		call_deferred("start_next_turn")

func determine_turn_order():
	# Collect all characters (player and enemies) into a single array
	var all_characters = [player]
	all_characters.append_array(mobs)

	# Sort characters by speed in descending order
	all_characters.sort_custom(compare_speed)
	
	# Store the initial turn order
	initial_turn_order = all_characters.duplicate()
	
	# Track alive characters
	alive_characters = all_characters.duplicate()
	
	# Clear turn queue and repopulate it with the sorted characters
	turn_queue.clear()
	turn_queue.append_array(all_characters)

func compare_speed(a, b):
		# Compare speed of characters for sorting
		var speed_a = get_speed(a)
		var speed_b = get_speed(b)
		
		if speed_a > speed_b :
			return true
		return false
		
func get_speed(character):
		# Get speed of the character from its StatsComponent
		var stats_component = character.get_node("StatsComponent")
		if stats_component:
			return stats_component.SPEED
		else:
			# Default to a speed of 0 if StatsComponent is not found
			return 0

func start_next_turn():
	# Check if battle has started and there are characters remaining
	if startBattle:
		# Refill turn queue if empty
		if turn_queue.is_empty():
			turn_queue.append_array(alive_characters)
		
		if turn_queue.size() == 0:
			return
		
		var next_character = turn_queue.pop_front()

		if next_character == player:
			start_player_turn()
		else:
			start_enemy_turn(next_character)

func character_died(character):
	# Remove character from alive_characters and initial_turn_order
	alive_characters.erase(character)
	initial_turn_order.erase(character)
	# Remove character from turn_queue if present
	turn_queue.erase(character)
	# Optionally, check if battle should end (all enemies or player dead)
	if character != player:
		mobs.erase(character)
	if character == player:
		startBattle = false
		battle_log.update_message("You died")
		await get_tree().create_timer(1.0).timeout
		GameState.reset_character()
	elif alive_characters.size() == 1 and alive_characters[0] == player:
		startBattle = false
		await get_tree().create_timer(1.0).timeout
		enemies.queue_free()
		battle_log.update_message("You won! Total Experience: %d" % [GameState.player_exp])
		await get_tree().create_timer(1.5).timeout
		$"..".finishingBattle()
	elif alive_characters.size() == 0:
		battle_log.update_message("You died")
		startBattle = false
		GameState.reset_character()

func start_player_turn():
	current_turn = TurnState.PLAYER_TURN
	# Enable player input or other turn-specific logic
	player.turn_start()

func start_enemy_turn(enemy):
	current_turn = TurnState.ENEMY_TURN
	# Execute the turn for the enemy if it still exists
	if enemy and alive_characters.has(enemy):
		enemy.turn_start()
	else:
		# If the enemy does not exist, immediately start the next turn
		start_next_turn()

func char_take_damage(damage: int):
	player.take_damage(damage)
	
func _on_mob_died(mob):
	GameState.earn_experience(mob.mob_exp, mob.mob_elem, mob.mob_released_currency)
	character_died(mob)
	
func _on_player_died():
	character_died(player)
	
	
func get_target_mob(mob_attacked : String):
	match mob_attacked:
		"mobA":
			return enemies.get_child(0)
		"mobB":
			return enemies.get_child(1)
		"mobC":
			return enemies.get_child(2)
		"mobD":
			return enemies.get_child(3)
