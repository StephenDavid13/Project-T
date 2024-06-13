extends Area2D

@onready var panel_sign_save = $Sprite2D/PanelSignSave
@onready var panel_sign_load = $Sprite2D/PanelSignLoad
@onready var game_manager = $"../game_manager"

@export var target_level : String

func _on_body_entered(body):
	if body.name == "main_char":
		panel_sign_save.visible = true
		panel_sign_load.visible = true
		game_manager.changeIsInSign(true)
		game_manager.target_level = target_level

		
func _on_body_exited(body):
	if (body.name == "main_char"):
		panel_sign_save.visible = false
		panel_sign_load.visible = false
		game_manager.changeIsInSign(false)
		
