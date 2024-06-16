extends Area2D

func _on_body_entered(body):
	if body.name == "main_char":
		GameState.tower_level += 1
		if GameState.tower_level > GameState.highest_tower_level:
			GameState.highest_tower_level = GameState.tower_level
		call_deferred("to_the_tower")
		
func to_the_tower():
	GameState.on_tower = true
	get_tree().change_scene_to_file("res://scenes/main_scenes/level_dungeon.tscn")
