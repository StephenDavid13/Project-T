extends Area2D

@onready var panel_sign = $Sprite2D/PanelSign
@onready var game_manager = $"../game_manager"

@export var target_level : String

func _on_body_entered(body):
	if body.name == "main_char":
		panel_sign.visible = true
		game_manager.changeIsInSign(true)
		game_manager.target_level = target_level

		
func _on_body_exited(body):
	if (body.name == "main_char"):
		panel_sign.visible = false
		game_manager.changeIsInSign(false)
		game_manager.target_level = target_level
		
