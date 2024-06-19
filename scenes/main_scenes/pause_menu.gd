extends Control

@onready var resumegame = $VBoxContainer/ResumeGame
@onready var savegame = $VBoxContainer/HBoxContainer/SaveGame
@onready var loadgame = $VBoxContainer/HBoxContainer/LoadGame
@onready var mainmenu = $VBoxContainer/MainMenu

# Called when the node enters the scene tree for the first time.
func _ready():
	resumegame.grab_focus()
	
	if not FileAccess.file_exists("user://savegame.save"):
		loadgame.disabled = true
 
	resumegame.pressed.connect(self._on_resume_game)
	savegame.pressed.connect(self._on_save_game)
	loadgame.pressed.connect(self._on_load_game)
	mainmenu.pressed.connect(self._on_mainmenu)
	
	update_player()
	update_stats()
	update_orbs()
	update_mods()
	
func _on_resume_game():
	GameState.toggle_pause()
	
func _on_save_game():
	GameState.save_data()
	
func _on_load_game():
	GameState.reset_character()
	GameState.load_data()
	GameState.toggle_pause()
	
func _on_mainmenu():
	GameState.toggle_pause()
	get_tree().change_scene_to_file("res://scenes/main_scenes/starting_menu.tscn")

func update_player():
	$"../HBoxContainer/MainPlayerStuff/StatsContainer/LabelName".text = GameState.player_name
	$"../HBoxContainer/MainPlayerStuff/StatsContainer/LabelVelices".text = "Velices: %d" % GameState.player_exp
	$"../HBoxContainer/MainPlayerStuff/StatsContainer/LabelHighestLevel".text = "Highest tower level: %d" % GameState.highest_tower_level	

func update_stats():
	$"../HBoxContainer/CurrentStats/StatsContainer/LabelStrength".text = "Strength: %d" % GameState.player_strength
	$"../HBoxContainer/CurrentStats/StatsContainer/LabelVitality".text = "Vitality: %d" % GameState.player_vitality
	$"../HBoxContainer/CurrentStats/StatsContainer/LabelIntelligence".text = "Intelligence: %d" % GameState.player_intelligence
	$"../HBoxContainer/CurrentStats/StatsContainer/LabelSpeed".text = "Speed: %d" % GameState.player_speed
	
func update_orbs():
	$"../HBoxContainer/CurrentOrbs/StatsContainer/LabelWater".text = "Water Orbs: %d" % GameState.currency_water
	$"../HBoxContainer/CurrentOrbs/StatsContainer/LabelEarth".text = "Earth Orbs: %d" % GameState.currency_earth
	$"../HBoxContainer/CurrentOrbs/StatsContainer/LabelFire".text = "Fire Orbs: %d" % GameState.currency_fire
	$"../HBoxContainer/CurrentOrbs/StatsContainer/LabelWind".text = "Wind Orbs: %d" % GameState.currency_wind
	
func update_mods():
	for i in range($"../HBoxContainer/WeaponMods/ModsContainer".get_child_count()):
		$"../HBoxContainer/WeaponMods/ModsContainer".get_child(i).text = GameState.all_mods_label[i]
