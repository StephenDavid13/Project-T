extends Area2D

@onready var main_char = $"../../main_char"
@onready var camera_2d = $"../../main_char/Camera2D"
@onready var battle_game_manager = $"../../battle_game_manager"

const SMOOTH_CAMERA_GO = 575

func _on_body_entered(body):
	if body.name == "main_char":
		battle_game_manager.battle_start = true

