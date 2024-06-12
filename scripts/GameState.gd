extends Node

# Get main_char
var main_char : Node = null
var is_initialized : bool = false
enum DungeonState { PRE_BATTLE, BATTLING, POST_BATTLE }

# Game State variables
var player_max_health : int
var player_current_health : int
var player_exp : int
var tower_level : int

var player_strength : int
var player_vitality : int
var player_intelligence : int
var player_speed : int

var on_tower = false

# Method to reset player world
func reset_character():
	on_tower = false
	tower_level = 1
	player_exp = 0
	player_current_health = player_max_health
	get_tree().change_scene_to_file("res://scenes/main_scenes/outside_tower.tscn")
	
# Earning experience
func earn_experience(experience : int):
	player_exp += experience
	
# Functions for increasing stats
func increase_strength():
	player_strength += 5
	
func increase_vitality():
	player_vitality += 10
	player_current_health += 10
	player_max_health += 10
	main_char.update_health_bar()
	
func increase_intelligence():
	player_intelligence += 5
	
func increase_speed():
	player_speed += 10
