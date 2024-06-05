extends CharacterBody2D

@onready var main_char = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var can_move = true
var can_battle = false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if can_move :
		if (velocity.x > 1 || velocity.x < -1):
			main_char.animation = "running"
		else:
			main_char.animation = "default"
			
		if not is_on_floor():
			velocity.y += gravity * delta

		var direction = Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, 12)

		move_and_slide()
		
		var isLeft = velocity.x < 0
		main_char.flip_h = isLeft
	elif can_battle : 
		main_char.animation = "default"
	else:
		velocity.x = 0
		main_char.animation = "default"

func turn_start():
	$ActionPanel.is_player_turn = true
	$ActionPanel.update_button_state()

func _on_turn_end():
	# Signal TurnManager to switch to enemy turn
	can_battle = false
	await $"../TurnManager".start_next_turn()
	
func _on_attack():
	main_char.play("attack")
