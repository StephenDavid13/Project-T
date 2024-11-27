extends Node

@onready var main_char = $"main_char"
@onready var enemies = $enemies
@onready var camera_2d = $"main_char/Camera2D"
@onready var enemy_spawn_1 = $"enemies_spawn/enemy_spawn_1"
@onready var turnManager = $TurnManager

var mob1 : Node2D

func _ready():
	# Focus on the very first button so it does not need mouse click
	$main_char/ActionPanel.update_button_state()

# Called when battle is initiated. Only done once per level. Disallow player
# movement and change camera view
func enteringBattle():
	main_char.current_battle_state = GameState.DungeonState.BATTLING
	main_char.can_move = false;
	camera_2d.position_smoothing_enabled = true
	camera_2d.position_smoothing_speed = 3
	camera_2d.move_local_x(545, true)
	spawnBoss()
	turnManager.start_battle()

# Called when battle is finished. Allow player to move again
func finishingBattle():
	main_char.current_battle_state = GameState.DungeonState.POST_BATTLE
	camera_2d.move_local_x(-545, true)
	await get_tree().create_timer(2.5).timeout
	main_char.can_move = true;
	camera_2d.position_smoothing_enabled = false
	$main_char/ActionPanel.post_battle_selection()

# Randomise monster amount and call randomiseMonsterSpawn() to instantiate their type
func spawnBoss():
	mob1 = preload("res://scenes/subscenes/enemies/enemy_skeleton.tscn").instantiate()
	mob1.position = enemy_spawn_1.position
	enemies.call_deferred("add_child", mob1)
	
