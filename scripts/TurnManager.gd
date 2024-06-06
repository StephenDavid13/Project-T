extends Node

enum TurnState { PLAYER_TURN, ENEMY_TURN }

var current_turn = TurnState.PLAYER_TURN
var player : CharacterBody2D
var enemies : Node
var startBattle : bool = false
var turn_queue = []
var initial_turn_order = []
var alive_characters = []

func _ready():
	# Initialize player and enemies
	player = $"../main_char"
	enemies = $"../enemies"

func start_battle():
	if not startBattle:
		startBattle = true
		await get_tree().create_timer(1.5).timeout
		determine_turn_order()
		call_deferred("start_next_turn")

func determine_turn_order():
	# Collect all characters (player and enemies) into a single array
	var all_characters = [player]
	all_characters.append_array(enemies.get_children())
	print(enemies.get_children())

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
		
		if speed_a < speed_b :
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
			print("Battle over. No more characters.")
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
	if character == player:
		print("Player has died. Battle over.")
		startBattle = false
	elif alive_characters.size() == 1 and alive_characters[0] == player:
		print("All enemies defeated. Battle won!")
		startBattle = false
	elif alive_characters.size() == 0:
		print("All characters are dead. Battle over.")
		startBattle = false

func start_player_turn():
	current_turn = TurnState.PLAYER_TURN
	print("Player's Turn")
	# Enable player input or other turn-specific logic
	player.turn_start()

func start_enemy_turn(enemy):
	current_turn = TurnState.ENEMY_TURN
	# Execute the turn for the enemy
	enemy.turn_start()
