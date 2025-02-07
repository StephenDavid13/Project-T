extends Control

# Assuming you use a ProgressBar for simplicity
var health_bar: ProgressBar
var health_label: Label

func _ready():
	health_bar = $HealthProgressBar
	health_label = $HealthLabel

# Function to update the health bar
func update_health(current_health: int, max_health: int):
	health_bar.value = current_health
	health_bar.max_value = max_health
	health_label.text = "%d/%d" % [current_health, max_health]
