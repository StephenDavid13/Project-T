extends Control

@onready var health_bar = $Panel/HealthProgressBar
@onready var health_label = $Panel/HealthProgressBar/HealthLabel
@onready var player_name = $Panel/Name
@onready var player_exp = $Panel/Velices
@onready var tower_level = $Panel2/TowerLevel

func _ready():
	if GameState.on_tower:
		tower_level.text = "Tower level: %d" % [GameState.tower_level]
		$Panel2.show()
	else:
		$Panel2.hide()
		
func _process(_delta):
	if GameState.is_paused:
		$Panel.hide()
	else:
		$Panel.show()

func update_health(current_health: int, max_health: int):
	health_bar.max_value = max_health
	health_bar.value = current_health
	health_label.text = "%d / %d" % [current_health, max_health]
	
func update_exp(message):
	player_exp.text = message
	
