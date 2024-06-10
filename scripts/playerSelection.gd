extends Control

var is_player_turn = false
var character : CharacterBody2D

func _ready():
	character = $".."
	$Battling_actions/attackBtn.pressed.connect(self._on_attack_button_pressed)
	$Battling_actions/defendBtn.pressed.connect(self._on_defend_button_pressed)
	$Battling_actions/healBtn.pressed.connect(self._on_heal_button_pressed)
	
	$PostBattling_actions/GoForwardBtn.pressed.connect(self._on_forward_button_pressed)
	$PostBattling_actions/GoBackBtn.pressed.connect(self._on_backward_button_pressed)

func _on_attack_button_pressed():
	character._on_attack()
	ending_turn()

func _on_defend_button_pressed():
	character._on_defend()
	ending_turn()

func _on_heal_button_pressed():
	character._on_heal()
	ending_turn()
	
func _on_forward_button_pressed():
	character._on_next_tower()
	$PostBattling_actions.hide()
	
func _on_backward_button_pressed():
	character._on_back_outside()
	$PostBattling_actions.hide()

# Helper functions
func ending_turn():
	is_player_turn = false
	update_button_state()
	character._on_turn_end()
	
func update_button_state():
	if not is_player_turn: 
		$Battling_actions.hide()
		$PostBattling_actions.hide()
	else:
		$Battling_actions.show()
		$Battling_actions/attackBtn.grab_focus()
	for child in $Battling_actions.get_children():
			if child is Button:
				child.disabled = not is_player_turn
				
func post_battle_selection():
	$PostBattling_actions.show()
	$PostBattling_actions/GoForwardBtn.grab_focus()
