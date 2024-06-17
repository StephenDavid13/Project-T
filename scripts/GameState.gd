extends Node

# Get main_char
var main_char : Node = null
var is_initialized : bool = false
enum DungeonState { PRE_BATTLE, BATTLING, POST_BATTLE }

# Game State variables
var player_name : String
var player_max_health : int
var player_current_health : int
var player_exp : int
var tower_level : int = 1
var highest_tower_level : int = 1

var raw_player_strength : int
var raw_player_vitality : int
var raw_player_intelligence : int
var raw_player_speed : int

var player_strength : int
var player_vitality : int
var player_intelligence : int
var player_speed : int

var currency_water : int = 0
var currency_earth : int = 0
var currency_fire : int = 0
var currency_wind : int = 0

var water_imbued : int = 1
var earth_imbued : int = 1
var fire_imbued : int = 1
var wind_imbued : int = 1

var mod_slots : int = 0
var all_mods_text : Array = []
var all_mods_percentage : Array = []
var all_mods_label : Array = ["--- Empty Mod ---", "--- Empty Mod ---", "--- Empty Mod ---", "--- Empty Mod ---"]

var on_tower = false

# Method to reset player world
func reset_character():
	on_tower = false
	tower_level = 1
	player_exp = 0
	player_current_health = player_max_health
	get_tree().change_scene_to_file("res://scenes/main_scenes/outside_tower.tscn")
	
# Earning experience
func earn_experience(experience : int, mob_elem : String, mob_currency : int):
	player_exp += experience
	match mob_elem:
		"Water":
			currency_water += mob_currency
		"Earth":
			currency_earth += mob_currency
		"Fire":
			currency_fire += mob_currency
		"Wind":
			currency_wind += mob_currency
	main_char.update_exp()
	
# Functions for increasing stats raw
func increase_strength_raw(inc_stat : int):
	raw_player_strength += inc_stat
	increase_strength()
	
func increase_vitality_raw(inc_stat : int):
	raw_player_vitality += inc_stat
	increase_vitality()
	
func increase_intelligence_raw(inc_stat : int):
	raw_player_intelligence += inc_stat
	increase_intelligence()
	
func increase_speed_raw(inc_stat : int):
	raw_player_speed += inc_stat
	increase_speed()
	
# Functions for increasing stats mods
func increase_strength_mod(inc_stat : float):
	all_mods_text.insert(mod_slots, "Strength")
	all_mods_percentage.insert(mod_slots, inc_stat)
	increase_strength()
	
func increase_vitality_mod(inc_stat : float):
	all_mods_text.insert(mod_slots, "Vitality")
	all_mods_percentage.insert(mod_slots, inc_stat)
	increase_vitality()
	
func increase_intelligence_mod(inc_stat : float):
	all_mods_text.insert(mod_slots, "Intelligence")
	all_mods_percentage.insert(mod_slots, inc_stat)
	increase_intelligence()
	
func increase_speed_mod(inc_stat : float):
	all_mods_text.insert(mod_slots, "Speed")
	all_mods_percentage.insert(mod_slots, inc_stat)
	increase_speed()
	
# Functions for increasing stats
func increase_strength():
	player_strength = raw_player_strength
	for i in range(all_mods_text.size()):
		if all_mods_text[i] == "Strength":
			player_strength =  ceil((all_mods_percentage[i] * player_strength) + player_strength)
	
func increase_vitality():
	player_vitality = raw_player_vitality
	for i in range(all_mods_text.size()):
		if all_mods_text[i] == "Vitality":
			player_vitality = ceil((all_mods_percentage[i] * player_vitality) + player_vitality)

	player_current_health = player_vitality
	player_max_health = player_vitality
	main_char.update_health_bar()
	
func increase_intelligence():
	player_intelligence = raw_player_intelligence
	for i in range(all_mods_text.size()):
		if all_mods_text[i] == "Intelligence":
			player_intelligence = ceil((all_mods_percentage[i] * player_intelligence) + player_intelligence)
	
func increase_speed():
	player_speed = raw_player_speed
	for i in range(all_mods_text.size()):
		if all_mods_text[i] == "Intelligence":
			player_speed = ceil((all_mods_percentage[i] * player_speed) + player_speed)

func reset_mods():
	all_mods_text.clear()
	all_mods_percentage.clear()
	all_mods_label.assign(["--- Empty Mod ---", "--- Empty Mod ---", "--- Empty Mod ---", "--- Empty Mod ---"])
	mod_slots = 0
	increase_strength_raw(0)
	increase_vitality_raw(0)
	increase_intelligence_raw(0)
	increase_speed_raw(0)
	water_imbued = 1
	earth_imbued = 1
	fire_imbued = 1
	wind_imbued = 1
	player_exp -= 200
	
func save_data():
	var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	
	var save_dict = {
		"filename": get_parent().get_path(),
		"player_name": player_name,
		"player_max_health": player_max_health,
		"player_exp": player_exp,
		"highest_tower_level": highest_tower_level,
		
		"player_strength": player_strength,
		"player_vitality": player_vitality,
		"player_intelligence": player_intelligence,
		"player_speed": player_speed,
		
		"raw_player_strength": raw_player_strength,
		"raw_player_vitality": raw_player_vitality,
		"raw_player_intelligence": raw_player_intelligence,
		"raw_player_speed": raw_player_speed,
		
		"currency_water": currency_water,
		"currency_earth": currency_earth,
		"currency_fire": currency_fire,
		"currency_wind": currency_wind,
		"water_imbued": water_imbued,
		"earth_imbued": earth_imbued,
		"fire_imbued": fire_imbued,
		"wind_imbued": wind_imbued,
		
		"mod_slots": mod_slots,
		
		"all_mods_text": all_mods_text,
		"all_mods_percentage": all_mods_percentage,
		"all_mods_label": all_mods_label,
	}
	var json_string = JSON.stringify(save_dict)
	
	save_game.store_line(json_string)
	save_game.close()
	
func load_data():
	if not FileAccess.file_exists("user://savegame.save"):
		return 
	var save_game = FileAccess.open("user://savegame.save", FileAccess.READ)
	var save_data_str = save_game.get_as_text()
	var loading_data = JSON.parse_string(save_data_str)
	save_game.close()
	
	player_name = loading_data["player_name"]
	player_max_health = loading_data["player_max_health"]
	player_current_health = player_max_health
	player_exp = loading_data["player_exp"]
	highest_tower_level = loading_data["highest_tower_level"]
	
	player_strength = loading_data["player_strength"]
	player_vitality = loading_data["player_vitality"]
	player_intelligence = loading_data["player_intelligence"]
	player_speed = loading_data["player_speed"]
	
	raw_player_strength = loading_data["raw_player_strength"]
	raw_player_vitality = loading_data["raw_player_vitality"]
	raw_player_intelligence = loading_data["raw_player_intelligence"]
	raw_player_speed = loading_data["raw_player_speed"]
	
	currency_water = loading_data["currency_water"]
	currency_earth = loading_data["currency_earth"]
	currency_fire = loading_data["currency_fire"]
	currency_wind = loading_data["currency_wind"]
	water_imbued = loading_data["water_imbued"]
	earth_imbued = loading_data["earth_imbued"]
	fire_imbued = loading_data["fire_imbued"]
	wind_imbued = loading_data["wind_imbued"]
	
	mod_slots = loading_data["mod_slots"]
	
	all_mods_text.assign(loading_data["all_mods_text"])
	all_mods_percentage.assign(loading_data["all_mods_percentage"])
	all_mods_label.assign(loading_data["all_mods_label"])
		
	main_char.update_health_bar()
	main_char.update_exp()
