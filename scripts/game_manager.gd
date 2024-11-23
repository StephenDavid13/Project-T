extends Node

var isInSign = false
var isInShop = false
var isInBlacksmith = false
var target_level

func _ready():
	$"../main_char".position = GameState.player_poition
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		GameState.toggle_pause()
	
func _process(_delta):
	checkIfActionBeTriggered()
	
# Check if player is in a sign that needs to go somewhere
func checkIfActionBeTriggered():
	#Check if player are in a sign for them to go somewhere
	if Input.is_action_just_pressed("action_use") and isInSign :
		GameState.save_data()
		
	elif Input.is_action_just_pressed("action_alt") and isInSign :
		GameState.load_data()
		
	if Input.is_action_just_pressed("action_use") and isInShop :
		GameState.player_poition = $"../main_char".position
		get_tree().change_scene_to_file("res://scenes/main_scenes/shop_menu.tscn")
		
	elif Input.is_action_just_pressed("action_use") and isInBlacksmith :
		GameState.player_poition = $"../main_char".position
		get_tree().change_scene_to_file("res://scenes/main_scenes/blacksmith_menu.tscn")

func changeIsInSign(boolInSign):
	isInSign = boolInSign
	
func changeIsInShop(boolInShop):
	isInShop = boolInShop
	
func changeIsInBlacksmith(boolInBlacksmith):
	isInBlacksmith = boolInBlacksmith
