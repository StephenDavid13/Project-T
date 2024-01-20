extends Node

var isInSign = false
var target_level
	
func _ready():
	pass
	
func _process(_delta):
	#Check if player are in a sign for them to go somewhere
	if Input.is_action_just_pressed("action_use") and isInSign :
		if target_level == "goOutside" :
			get_tree().change_scene_to_file("res://scenes/main_scenes/outside_tower.tscn")	
		elif target_level == "goToBase" :
			get_tree().change_scene_to_file("res://scenes/main_scenes/main_scene_start.tscn")
			


func changeIsInSign(boolInSign):
	isInSign = boolInSign
