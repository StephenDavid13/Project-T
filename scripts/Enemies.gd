extends Node2D

@onready var enemy_animation = $RigidBody2D/AnimatedSprite2D
@onready var statsheet = $StatsComponent
@onready var health_bar = $HealthBar
@onready var level_label = $lvlLabel

@export var default_animation = "default"

var max_health : int
var current_health : int
var mob_strength : int
var mob_vitality : int
var mob_intelligence : int
var mob_speed : int
var mob_lvl : int = 1

var rng_generator = RandomNumberGenerator.new()

signal on_dead()

func _ready():
	# Connect the animation_finished signal
	checkTowerLevel()
	generateMobLvl()
	max_health = mob_vitality
	current_health = mob_vitality
	update_health_bar()
	enemy_animation.animation_finished.connect(self._on_animation_finished)

func _on_animation_finished():
	# This function is called when the animation finishes
	if enemy_animation.animation == "attack":
		reset_to_default_state()

func reset_to_default_state():
	enemy_animation.play(default_animation)
	# Notify the TurnManager that this enemy's turn is finished
	await $"../../TurnManager".start_next_turn()

func turn_start():
	enemy_animation.play("attack")
	var multiplier = randf_range(0, 2)
	var damage = floor((mob_strength + randi_range(1, mob_strength / 2)) * multiplier)
	$"../../TurnManager".char_take_damage(damage)
	
func generateMobLvl():
	print(mob_lvl)
	level_label.text = "Level: %d" % [mob_lvl]
	mob_strength = statsheet.STRENGTH * mob_lvl
	mob_vitality = statsheet.VITALITY * mob_lvl
	mob_intelligence = statsheet.INTELLIGENCE * mob_lvl
	mob_speed = statsheet.SPEED * mob_lvl
	
func take_damage(damage: int):
	current_health -= damage
	update_health_bar()
	if current_health <= 0:
		on_dead.emit()
		queue_free()
	
func update_health_bar():
	health_bar.update_health(current_health, max_health)
	
	
func checkTowerLevel():
	if GameState.tower_level > 39:
		mob_lvl = ceil(rng_generator.randi_range(8, 10))
	elif GameState.tower_level > 29:
		mob_lvl = ceil(rng_generator.randi_range(5, 8))
	elif GameState.tower_level > 19:
		mob_lvl = ceil(rng_generator.randi_range(4, 7))
	elif GameState.tower_level > 9:
		mob_lvl = ceil(rng_generator.randi_range(3, 6))
	elif GameState.tower_level >= 5:
		mob_lvl = ceil(rng_generator.randi_range(2, 4))
	elif GameState.tower_level >= 3:
		mob_lvl = ceil(rng_generator.randi_range(1, 3))
