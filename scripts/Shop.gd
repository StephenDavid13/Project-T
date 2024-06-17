extends Control

@onready var main_char = $"../CharacterBody2D"
@onready var stats_title = $CurrentStats/StatsContainer/LabelTitle
@onready var stats_strength = $CurrentStats/StatsContainer/LabelStrength
@onready var stats_vitality = $CurrentStats/StatsContainer/LabelVitality
@onready var stats_intelligence = $CurrentStats/StatsContainer/LabelIntelligence
@onready var stats_speed = $CurrentStats/StatsContainer/LabelSpeed

var items = [
	{"name": "Strength", "price": 100},
	{"name": "Vitality", "price": 100},
	{"name": "Intelligence", "price": 100},
	{"name": "Speed", "price": 100}
]

# Signals
signal item_purchased(item_name, item_price)

func _ready():
	populate_shop_items()
	main_char.hide()
	$Panel/CloseButton.pressed.connect(self._on_close_button_pressed)
	
	update_stats()

func populate_shop_items():
	var items_container_string = $Panel/HBoxContainer/ItemsContainerLabel
	var items_container_button = $Panel/HBoxContainer/ItemsContainer
	
	for item in items:
		var button = Button.new()
		var label = Label.new()
		
		label.text = item.name
		button.text = str(item.price) + "V"
		
		label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		label.vertical_alignment = 1
		button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		
		button.pressed.connect(_on_item_button_pressed.bind(item))
		items_container_button.add_child(button)
		items_container_string.add_child(label)
		
	if items_container_button.get_child_count() > 0:
		var first_button = items_container_button.get_child(0)
		first_button.grab_focus()

func update_stats():
	stats_title.text = "%s's stats" % GameState.player_name
	stats_strength.text = "Strength: %d" % GameState.player_strength
	stats_vitality.text = "Vitality: %d" % GameState.player_vitality
	stats_intelligence.text = "Intelligence: %d" % GameState.player_intelligence
	stats_speed.text = "Speed: %d" % GameState.player_speed
	pass

func _on_item_button_pressed(item):
	if GameState.player_exp >= item.price:
		GameState.player_exp -= item.price
		main_char.update_exp()
		match item.name:
			"Strength":
				GameState.increase_strength_raw(5)
			"Vitality":
				GameState.increase_vitality_raw(10)
			"Intelligence":
				GameState.increase_intelligence_raw(5)
			"Speed":
				GameState.increase_speed_raw(10)
		update_stats()

func _on_close_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_scenes/outside_tower.tscn")
	queue_free()  # Closes the shop
