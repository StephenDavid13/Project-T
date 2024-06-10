extends Area2D

func _on_body_entered(body):
	if body.name == "main_char":
		GameState.tower_level += 1
		get_tree().change_scene_to_file("res://scenes/main_scenes/level_dungeon.tscn")
