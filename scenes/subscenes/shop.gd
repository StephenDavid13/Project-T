extends Area2D

@onready var panel = $AnimatedSprite2D/Panel

func _on_body_entered(body):
	if body.name == "main_char":
		panel.visible = true

		
func _on_body_exited(body):
	if body.name == "main_char":
		panel.visible = false
