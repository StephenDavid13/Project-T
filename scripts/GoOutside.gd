extends Area2D

func _on_body_entered(body):
	if body.name == "main_char":
		GameState.player_current_health = GameState.player_max_health
		GameState.on_tower = false
		get_tree().change_scene_to_file("res://scenes/main_scenes/outside_tower.tscn")
