extends Area2D

@onready var panel = $AnimatedSprite2D/PanelSign
@onready var game_manager = $"../game_manager"

func _on_body_entered(body):
	if body.name == "main_char":
		panel.visible = true
		game_manager.changeIsInShop(true)
		
func _on_body_exited(body):
	if body.name == "main_char":
		panel.visible = false
