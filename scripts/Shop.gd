extends Control

var items = [
	{"name": "Strength", "price": 100},
	{"name": "Vitality", "price": 100},
	{"name": "Intelligence", "price": 100},
	{"name": "Speed", "price": 100}
]

# Signals
signal item_purchased(item_name, item_price)

func _ready():
	update_currency_label()
	populate_shop_items()
	$Panel/CloseButton.pressed.connect(self._on_close_button_pressed)

func update_currency_label():
	$Panel/CurrencyLabel.text = "Velices: " + str(GameState.player_exp)

func populate_shop_items():
	var items_container = $Panel/ItemsContainer
	
	for item in items:
		var button = Button.new()
		button.text = item.name + " - " + str(item.price) + "V"
		button.pressed.connect(_on_item_button_pressed.bind(item))
		items_container.add_child(button)

func _on_item_button_pressed(item):
	if GameState.player_exp >= item.price:
		GameState.player_exp -= item.price
		update_currency_label()
		match item.name:
			"Strength":
				GameState.increase_strength()
			"Vitality":
				GameState.increase_vitality()
			"Intelligence":
				GameState.increase_intelligence()
			"Speed":
				GameState.increase_speed()
		print("Purchased: ", item.name)
	else:
		print("Not enough gold to buy: ", item.name)

func _on_close_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_scenes/outside_tower.tscn")
	queue_free()  # Closes the shop
