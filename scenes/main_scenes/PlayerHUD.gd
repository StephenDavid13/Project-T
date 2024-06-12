extends Control

@onready var health_bar = $Panel/HealthProgressBar
@onready var health_label = $Panel/HealthProgressBar/HealthLabel
@onready var player_name = $Panel/Name
@onready var player_exp = $Panel/Velices

func update_health(current_health: int, max_health: int):
	health_bar.value = current_health
	health_bar.max_value = max_health
	health_label.text = "%d / %d" % [current_health, max_health]
	
func update_exp(message):
	player_exp.text = message
