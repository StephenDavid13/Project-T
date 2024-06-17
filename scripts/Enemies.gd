extends Node2D

@onready var enemy_animation = $RigidBody2D/AnimatedSprite2D
@onready var statsheet = $StatsComponent
@onready var health_bar = $Panel/VBoxContainer/HealthBar
@onready var level_label = $Panel/VBoxContainer/lvlLabel
@onready var name_label = $Panel/VBoxContainer/nameLabel

@export var default_animation = "default"

var max_health : int
var current_health : int
var mob_strength : int
var mob_vitality : int
var mob_intelligence : int
var mob_speed : int
var mob_exp : int

var mob_lvl : int = 1
var mob_name : String
var mob_pos: String
var mob_elem : String
var mob_released_currency : int

var rng_generator = RandomNumberGenerator.new()

signal on_dead()

func _ready():
	# Connect the animation_finished signal
	start_create_mob()
	max_health = mob_vitality
	current_health = mob_vitality
	update_health_bar()	
	name_label.text = mob_name
	enemy_animation.animation_finished.connect(self._on_animation_finished)

func start_create_mob():
	generateMobLvl()
	insertName()
	generateElement()

# All animations
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
	
func take_damage(damage: int):
	current_health -= damage
	update_health_bar()
	if current_health <= 0:
		on_dead.emit()
		queue_free()
	
# Insert Names
func insertName():
	mob_name = "%s %s - Lvl: %d" % [statsheet.NAME, mob_pos, mob_lvl]
	
func insertPos(additional_name : String):
	mob_pos = additional_name
	
# Create levels
func generateMobLvl():
	var lvl_modifier = 1
	checkTowerLevel()
	if mob_lvl > 1:
		lvl_modifier = (mob_lvl * 0.5) + 0.5
	mob_strength = statsheet.STRENGTH * lvl_modifier
	mob_vitality = ceil(statsheet.VITALITY * mob_lvl)
	mob_intelligence = statsheet.INTELLIGENCE * mob_lvl
	mob_speed = ceil(statsheet.SPEED * mob_lvl)
	mob_exp = floor(statsheet.EXPERIENCE * mob_lvl)
	
	generateCurrency(lvl_modifier)

# Add element
func generateElement():
	var element = rng_generator.randi_range(0, 3)
	match element:
		0:
			mob_elem = "Water"
		1:
			mob_elem = "Earth"
		2:
			mob_elem = "Fire"
		3:
			mob_elem = "Wind"
	level_label.text = "%s" % [mob_elem]
	
func generateCurrency(lvl_modifier : int):
	mob_released_currency = (rng_generator.randi_range(1, 10) * 5) * lvl_modifier
	
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
		
# Random function helpers
func update_health_bar():
	health_bar.update_health(current_health, max_health)
