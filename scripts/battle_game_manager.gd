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
	main_char.current_battle_state = GameState.DungeonState.BATTLING
	main_char.can_move = false;
	camera_2d.position_smoothing_enabled = true
	camera_2d.position_smoothing_speed = 2
	camera_2d.move_local_x(545, true)
	spawnMonster()
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
func spawnMonster():
	
	var spawn_number_rng = rng_generator.randi_range(4, 4)
	var mobs = [mob1, mob2, mob3, mob4]
	var spawn_pos = [enemy_spawn_1.position, enemy_spawn_2.position, enemy_spawn_3.position, enemy_spawn_4.position]
	
	for i in range(spawn_number_rng):
		randomiseMonsterSpawn(mobs[i], spawn_pos[i], i)
		if i < spawn_number_rng - 1:
			await get_tree().create_timer(0.1).timeout

# Randomise moonster spawn and instantiate them
func randomiseMonsterSpawn(mob, spawn_position, mob_name):
	var type_rng = rng_generator.randi_range(0, 1)
	match type_rng:
		0:
			mob = preload("res://scenes/subscenes/enemies/enemy_skeleton.tscn").instantiate()
		1:
			mob = preload("res://scenes/subscenes/enemies/enemy_goblin.tscn").instantiate()
	mob.position = spawn_position
	enemies.call_deferred("add_child", mob)
	match mob_name:
		0: 
			mob.insertPos("A")
		1:
			mob.insertPos("B")
		2:
			mob.insertPos("C")
		3:
			mob.insertPos("D")
