extends CharacterBody2D

@onready var main_char = $AnimatedSprite2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var can_move = true
var did_attack = false

var max_health :int
var current_health : int
var health_bar: Control

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	max_health = $StatsComponent.VITALITY
	current_health = $StatsComponent.VITALITY
	health_bar = $HealthBar
	update_health_bar()

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
	elif did_attack :
		print("ATTACKING")
		main_char.play("attack")
	else:
		velocity.x = 0
		main_char.animation = "default"

func turn_start():
	$ActionPanel.is_player_turn = true
	$ActionPanel.update_button_state()

func _on_turn_end():
	# Signal TurnManager to switch to enemy turn
	await get_tree().create_timer(0.55).timeout
	did_attack = false
	$"../TurnManager".start_next_turn()
	
func take_damage(damage: int):
	current_health -= damage
	if current_health < 0:
		current_health = 0
	update_health_bar()

func update_health_bar():
	health_bar.update_health(current_health, max_health)

	
func _on_attack():
	did_attack = true
	
