extends Node

@onready var player = $main_char

# Define your stats here
var player_max_health : int
var player_current_health : int
var player_exp : int

# Other game state data can be added here

# Method to reset player health  
func reset_character():
	player_exp = 0
	player_current_health = player_max_health
	get_tree().change_scene_to_file("res://scenes/main_scenes/outside_tower.tscn")
	
func earn_experience(experience : int):
	player_exp += experience
