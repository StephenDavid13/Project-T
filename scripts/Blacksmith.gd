extends Control

@onready var main_char = $"../CharacterBody2D"

@onready var curr_water = $CurrentOrbs/StatsContainer/LabelWater
@onready var curr_earth = $CurrentOrbs/StatsContainer/LabelEarth
@onready var curr_fire = $CurrentOrbs/StatsContainer/LabelFire
@onready var curr_wind = $CurrentOrbs/StatsContainer/LabelWind

@onready var stats_title = $CurrentStats/StatsContainer/LabelTitle
@onready var stats_strength = $CurrentStats/StatsContainer/LabelStrength
@onready var stats_vitality = $CurrentStats/StatsContainer/LabelVitality
@onready var stats_intelligence = $CurrentStats/StatsContainer/LabelIntelligence
@onready var stats_speed = $CurrentStats/StatsContainer/LabelSpeed

@onready var mod1 = $WeaponMods/ModsContainer/LabelMod1
@onready var mod2 = $WeaponMods/ModsContainer/LabelMod2
@onready var mod3 = $WeaponMods/ModsContainer/LabelMod3
@onready var mod4 = $WeaponMods/ModsContainer/LabelMod4

@onready var chatbox = $"../AnimatedSprite2D/Chatbox"
@onready var chatbox_text = $"../AnimatedSprite2D/Chatbox/RichTextLabel"

var all_mods : Array


var items = [
	{"name": "Water Upgrade", "price": 100},
	{"name": "Earth Upgrade", "price": 100},
	{"name": "Fire Upgrade", "price": 100},
	{"name": "Wind Upgrade", "price": 100}
]

var rng_generator = RandomNumberGenerator.new()

# Signals
signal item_purchased(item_name, item_price)

func _ready():
	all_mods.assign([mod1, mod2, mod3, mod4])
	
	for i in range(all_mods.size()):
		all_mods[i].text = GameState.all_mods_label[i]
	
	populate_shop_items()
	
	update_stats()
	main_char.hide()
	$Panel/CloseButton.pressed.connect(self._on_close_button_pressed)
	$Panel/ResetButton.pressed.connect(self._on_reset_mods)
	
	update_orbs()

func populate_shop_items():
	var items_container_string = $Panel/HBoxContainer/ItemsContainerLabel
	var items_container_button = $Panel/HBoxContainer/ItemsContainer
	
	for child in items_container_string.get_children():
		child.queue_free()
	for child in items_container_button.get_children():
		child.queue_free()
	
	for item in items:
		var button = Button.new()
		var label = Label.new()
		
		label.text = item.name
		button.text = str(item.price) + " Orbs"
		
		label.size_flags_vertical = Control.SIZE_EXPAND_FILL
		label.vertical_alignment = 1
		button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		
		update_prices(button, item)
		
		button.pressed.connect(_on_item_button_pressed.bind(button, item))
		items_container_button.add_child(button)
		items_container_string.add_child(label)
		
	if items_container_button.get_child_count() > 0:
		var first_button = items_container_button.get_child(0)
		first_button.grab_focus()

func update_orbs():
	stats_title.text = "%s's stats" % GameState.player_name
	curr_water.text = "Water Orbs: %d" % GameState.currency_water
	curr_earth.text = "Earth Orbs: %d" % GameState.currency_earth
	curr_fire.text = "Fire Orbs: %d" % GameState.currency_fire
	curr_wind.text = "Wind Orbs: %d" % GameState.currency_wind
	
func update_stats():
	stats_title.text = "%s's stats" % GameState.player_name
	stats_strength.text = "Strength: %d" % GameState.player_strength
	stats_vitality.text = "Vitality: %d" % GameState.player_vitality
	stats_intelligence.text = "Intelligence: %d" % GameState.player_intelligence
	stats_speed.text = "Speed: %d" % GameState.player_speed

func update_prices(button : Button, item):
	match item.name:
		"Water Upgrade":
			item.price = (GameState.water_imbued * 200) - 100
		"Earth Upgrade":
			item.price = (GameState.earth_imbued * 200) - 100
		"Fire Upgrade":
			item.price = (GameState.fire_imbued * 200) - 100
		"Wind Upgrade":
			item.price = (GameState.wind_imbued * 200) - 100
	button.text = str(item.price) + " Orbs"

func _on_item_button_pressed(button : Button, item):
	if GameState.mod_slots < 4:
		match item.name:
			"Water Upgrade":
				if GameState.currency_water >= item.price:
					GameState.currency_water -= item.price
					GameState.water_imbued += 1
					do_upgrade("water")
			"Earth Upgrade":
				if GameState.currency_earth >= item.price:
					GameState.currency_earth -= item.price
					GameState.earth_imbued += 1
					do_upgrade("earth")
			"Fire Upgrade":
				if GameState.currency_fire >= item.price:
					GameState.currency_fire -= item.price
					GameState.fire_imbued += 1
					do_upgrade("fire")
			"Wind Upgrade":
				if GameState.currency_wind >= item.price:
					GameState.currency_wind -= item.price
					GameState.wind_imbued += 1
					do_upgrade("wind")
					
		update_prices(button, item)
	else:
		chatbox.show()
		chatbox_text.text = "No space for mods!"
		await get_tree().create_timer(2).timeout
		chatbox.hide()
	

func do_upgrade(element : String):
	var percentage = rng_generator.randi_range(10, 25)
	match element:
		"water":
			GameState.increase_intelligence_mod(float(percentage/100.0))
		"earth":
			GameState.increase_vitality_mod(float(percentage/100.0))
		"fire":
			GameState.increase_strength_mod(float(percentage/100.0))
		"wind":
			GameState.increase_speed_mod(float(percentage/100.0))
	update_mods(element, percentage)
	
func _on_reset_mods():
	if GameState.mod_slots > 0:
		GameState.reset_mods()
		for i in range(all_mods.size()):
			all_mods[i].text = GameState.all_mods_label[i]
	main_char.update_exp()
	update_stats()
	populate_shop_items()
	$Panel/ResetButton.grab_focus()
	
func update_mods(element: String, percentage : int):
	var stats = ""
	match element:
		"water":
			stats = "Intelligence"
		"earth":
			stats = "Vitality"
		"fire":
			stats = "Strength"
		"wind":
			stats = "Speed"
	for spec_mods in all_mods:
		if spec_mods.text == "--- Empty Mod ---" :
			spec_mods.text = "%s is increased by %d%%" % [stats, percentage]
			GameState.mod_slots+=1
			break
	update_orbs()
	update_stats()
	GameState.all_mods_label.assign([mod1.text, mod2.text, mod3.text, mod4.text])
	

func _on_close_button_pressed():
	get_tree().change_scene_to_file("res://scenes/main_scenes/outside_tower.tscn")
	queue_free()  # Closes the shop
