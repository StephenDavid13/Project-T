extends Control

var is_player_turn = false
var character : CharacterBody2D

func _ready():
	character = $".."
	$VBoxContainer/attackBtn.pressed.connect(self._on_attack_button_pressed)
	$VBoxContainer/defendBtn.pressed.connect(self._on_defend_button_pressed)
	$VBoxContainer/healBtn.pressed.connect(self._on_heal_button_pressed)

func _on_attack_button_pressed():
	print("Attack action selected")
	is_player_turn = false
	character._on_attack()
	update_button_state()
	character._on_turn_end()
	
	
func _on_defend_button_pressed():
	print("Defend action selected")
	is_player_turn = false
	update_button_state()
	character._on_turn_end()
	
func _on_heal_button_pressed():
	print("Heal action selected")
	is_player_turn = false
	update_button_state()
	character._on_turn_end()
	
func update_button_state():
	if not is_player_turn: 
		$VBoxContainer.hide()
	else:
		$VBoxContainer.show()
		$VBoxContainer/attackBtn.grab_focus()
	for child in $VBoxContainer.get_children():
			if child is Button:
				child.disabled = not is_player_turn
