extends Node2D

@onready var enemy_animation = $RigidBody2D/AnimatedSprite2D
@export var default_animation = "default"

func _ready():
	# Connect the animation_finished signal
	enemy_animation.animation_finished.connect(self._on_animation_finished)

func turn_start():
	print("Enemy Turn")
	enemy_animation.play("attack")

func _on_animation_finished():
	# This function is called when the animation finishes
	if enemy_animation.animation == "attack":
		reset_to_default_state()

func reset_to_default_state():
	enemy_animation.play(default_animation)
	# Notify the TurnManager that this enemy's turn is finished
	await $"../../TurnManager".start_next_turn()
