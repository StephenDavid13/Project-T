extends Node

@onready var main_char = $"../main_char"
@onready var camera_2d = $"../main_char/Camera2D"
@onready var enemy_spawn_1 = $"../enemies/enemy_spawn_1"
@onready var enemy_spawn_2 = $"../enemies/enemy_spawn_2"
@onready var enemy_spawn_3 = $"../enemies/enemy_spawn_3"
@onready var enemy_spawn_4 = $"../enemies/enemy_spawn_4"

var battle_start = false
var initial_battle_check = true
var skeleton = preload("res://scenes/subscenes/enemies/enemy_skeleton.tscn")
var goblin = preload("res://scenes/subscenes/enemies/enemy_goblin.tscn")
var rng_generator = RandomNumberGenerator.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if battle_start and initial_battle_check:
		enteringBattle()
		initial_battle_check = false
		
	if Input.is_action_just_pressed("action_use") and battle_start :
		finishingBattle()
		
# Called when battle is initiated. Only done once per level. Disallow player
# movement and change camera view
func enteringBattle():
	main_char.can_move = false;
	camera_2d.position_smoothing_enabled = true
	camera_2d.position_smoothing_speed = 2
	camera_2d.move_local_x(575, true)
	spawnMonster()

# Called when battle is finished. Allow player to move again
func finishingBattle():
	camera_2d.move_local_x(-575, true)
	await get_tree().create_timer(2.5).timeout
	battle_start = true
	main_char.can_move = true;
	camera_2d.position_smoothing_enabled = false

func randomiseMonsterSpawn(mob, spawn_position):
	var type_rng = rng_generator.randi_range(0, 1)
	match type_rng:
		0:
			mob = skeleton.instantiate()
		1:
			mob = goblin.instantiate()
	mob.position = spawn_position
	add_child(mob)
	
func spawnMonster():
	var spawn_number_rng = rng_generator.randi_range(1, 4)
	if spawn_number_rng >= 1:
		var mob1 : Node2D
		randomiseMonsterSpawn(mob1, enemy_spawn_1.position)
	if spawn_number_rng >= 2:
		var mob2 : Node2D
		randomiseMonsterSpawn(mob2, enemy_spawn_2.position)
	if spawn_number_rng >= 3:
		var mob3 : Node2D
		randomiseMonsterSpawn(mob3, enemy_spawn_3.position)
	if spawn_number_rng >= 4:
		var mob4 : Node2D
		randomiseMonsterSpawn(mob4, enemy_spawn_4.position)
