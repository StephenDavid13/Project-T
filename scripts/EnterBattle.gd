extends Area2D

@onready var battle_seq = $"../.."

const SMOOTH_CAMERA_GO = 575

func _on_body_entered(body):
	if body.name == "main_char":
		battle_seq.enteringBattle()

