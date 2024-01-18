extends Node

var isInSign = false
var target_level
	
func _ready():
	pass
	
func _process(_delta):
	if Input.is_action_just_pressed("action_use") and isInSign :
		if target_level == "goToBattle" :
			get_tree().change_scene_to_file("res://scenes/main_scenes/scene_1.tscn")	
		elif target_level == "goToBase" :
			get_tree().change_scene_to_file("res://scenes/main_scenes/main_scene_start.tscn")


func changeIsInSign(boolInSign):
	isInSign = boolInSign
