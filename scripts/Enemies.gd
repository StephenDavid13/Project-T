extends Node2D

@onready var enemy_animation = $RigidBody2D/AnimatedSprite2D
@export var default_animation = "default"

var max_health :int
var current_health : int
var health_bar: Control

func _ready():
	# Connect the animation_finished signal
	max_health = $StatsComponent.VITALITY
	current_health = $StatsComponent.VITALITY
	health_bar = $HealthBar
	update_health_bar()
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
	
func update_health_bar():
	health_bar.update_health(current_health, max_health)
