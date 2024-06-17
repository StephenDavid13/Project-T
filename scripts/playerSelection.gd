extends Control

@onready var choosing = $"../../ChooseOponent"
@onready var mobA = $"../../ChooseOponent/ButtonA"
@onready var mobB = $"../../ChooseOponent/ButtonB"
@onready var mobC = $"../../ChooseOponent/ButtonC"
@onready var mobD = $"../../ChooseOponent/ButtonD"

var is_player_turn = false
var character : CharacterBody2D

var all_buttons : Array

signal attack_A
signal attack_B
signal attack_C
signal attack_D

func _ready():
	all_buttons = [mobA, mobB, mobC, mobD]
	character = $".."
	$Battling_actions/attackBtn.pressed.connect(self._on_attack_button_pressed)
	$Battling_actions/defendBtn.pressed.connect(self._on_defend_button_pressed)
	$Battling_actions/healBtn.pressed.connect(self._on_heal_button_pressed)
	
	$PostBattling_actions/GoForwardBtn.pressed.connect(self._on_forward_button_pressed)
	$PostBattling_actions/GoBackBtn.pressed.connect(self._on_backward_button_pressed)
	
	mobA.pressed.connect(self._on_attacking.bind("mobA"))
	mobB.pressed.connect(self._on_attacking.bind("mobB"))
	mobC.pressed.connect(self._on_attacking.bind("mobC"))
	mobD.pressed.connect(self._on_attacking.bind("mobD"))

func _on_attack_button_pressed():
	choose_opponent()

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
func choose_opponent():
	choosing.show()
	$Battling_actions.hide()
	for mobs in range($"../../enemies".get_child_count()):
		if not $"../../enemies".get_child(mobs).dead:
			all_buttons[mobs].show()
	for button in all_buttons:
		if button.visible:
			button.grab_focus()
			break

func _on_attacking(mob : String):
	choosing.hide()
	for buttons in all_buttons:
		buttons.hide()
	character._on_attack(mob)
	ending_turn()
	
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
