extends Node

@onready var main_char = $"main_char"
@onready var enemies = $enemies
@onready var camera_2d = $"main_char/Camera2D"
@onready var enemy_spawn_1 = $"enemies_spawn/enemy_spawn_1"
@onready var enemy_spawn_2 = $"enemies_spawn/enemy_spawn_2"
@onready var enemy_spawn_3 = $"enemies_spawn/enemy_spawn_3"
@onready var enemy_spawn_4 = $"enemies_spawn/enemy_spawn_4"
@onready var turnManager = $TurnManager

var rng_generator = RandomNumberGenerator.new()

var mob1 : Node2D
var mob2 : Node2D
var mob3 : Node2D
var mob4 : Node2D

func _ready():
	# Focus on the very first button so it does not need mouse click
	$main_char/ActionPanel.update_button_state()

# Called when battle is initiated. Only done once per level. Disallow player
# movement and change camera view
func enteringBattle():
	main_char.current_battle_state = main_char.DungeonState.BATTLING
	main_char.can_move = false;
	camera_2d.position_smoothing_enabled = true
	camera_2d.position_smoothing_speed = 2
	camera_2d.move_local_x(545, true)
	spawnMonster()
	turnManager.start_battle()

# Called when battle is finished. Allow player to move again
func finishingBattle():
	camera_2d.move_local_x(-545, true)
	await get_tree().create_timer(2.5).timeout
	main_char.can_move = true;
	camera_2d.position_smoothing_enabled = false
	main_char.current_battle_state = main_char.DungeonState.POST_BATTLE
	$main_char/ActionPanel.post_battle_selection()

# Randomise monster amount and call randomiseMonsterSpawn() to instantiate their type
func spawnMonster():
	var spawn_number_rng = rng_generator.randi_range(1, 4)
	if spawn_number_rng >= 1:
		randomiseMonsterSpawn(mob1, enemy_spawn_1.position)
		await get_tree().create_timer(0.1).timeout
	if spawn_number_rng >= 2:
		randomiseMonsterSpawn(mob2, enemy_spawn_2.position)
		await get_tree().create_timer(0.1).timeout
	if spawn_number_rng >= 3:
		randomiseMonsterSpawn(mob3, enemy_spawn_3.position)
		await get_tree().create_timer(0.1).timeout
	if spawn_number_rng >= 4:
		randomiseMonsterSpawn(mob4, enemy_spawn_4.position)

# Randomise moonster spawn and instantiate them
func randomiseMonsterSpawn(mob, spawn_position):
	var type_rng = rng_generator.randi_range(0, 1)
	match type_rng:
		0:
			mob = preload("res://scenes/subscenes/enemies/enemy_skeleton.tscn").instantiate()
		1:
			mob = preload("res://scenes/subscenes/enemies/enemy_goblin.tscn").instantiate()
	mob.position = spawn_position
	enemies.call_deferred("add_child", mob)
