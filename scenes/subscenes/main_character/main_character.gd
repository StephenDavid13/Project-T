extends CharacterBody2D

@onready var main_char = $AnimatedSprite2D
@onready var statsheet = $StatsComponent
@onready var health_bar = $HealthBar

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var can_move = true
var did_attack = false
var did_heal = false
var did_defend = false

var max_health : int
var defend : int

signal on_dead()
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var rng_generator = RandomNumberGenerator.new()

func _ready():
	set_max_health_gamestate()
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
	var final_damage = damage
	if did_defend:
		final_damage -= defend
		if final_damage <= 0:
			final_damage = 0
		did_defend = false
		defend = 0
	GameState.player_current_health -= final_damage
	print("Monster final damage with ", final_damage)
	if GameState.player_current_health <= 0:
		GameState.player_current_health = GameState.player_max_health
		update_health_bar()
		on_dead.emit()
	update_health_bar()

func update_health_bar():
	health_bar.update_health(GameState.player_current_health, max_health)

func set_max_health_gamestate():
	max_health = statsheet.VITALITY
	GameState.player_max_health = max_health
	
	if GameState.player_current_health == 0:
		GameState.player_current_health = statsheet.VITALITY
	
func _on_attack():
	did_attack = true
	var damage = ceil((statsheet.STRENGTH * randi_range(0, (statsheet.STRENGTH/2))) + (statsheet.STRENGTH / 2))
	print("Player attacked with ", damage)
	$"../TurnManager".get_frontmost_mob().take_damage(damage)

func _on_defend():
	did_defend = true
	defend = floor((statsheet.STRENGTH + statsheet.VITALITY) * 0.125)
	print("Player defended with ", defend)
	
func _on_heal():
	did_heal = true
	var heal = floor(statsheet.INTELLIGENCE * randf_range(0.9, 1.5))
	var new_health = GameState.player_current_health + heal
	if new_health >= GameState.player_max_health:
		GameState.player_current_health = GameState.player_max_health
	else:
		GameState.player_current_health += heal
	print("Player heal with ", heal)
	update_health_bar()
	
