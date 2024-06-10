extends CharacterBody2D

@onready var main_char = $AnimatedSprite2D
@onready var statsheet = $StatsComponent
@onready var health_bar = $HealthBar

# Random stuff
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var rng_generator = RandomNumberGenerator.new()
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

enum DungeonState { PRE_BATTLE, BATTLING, POST_BATTLE }
var current_battle_state = DungeonState.PRE_BATTLE

# What player gonna do
var can_move = true
var go_forward = false
var go_back = false

var did_attack = false
var did_heal = false
var did_defend = false

var max_health : int
var defend : int

signal on_dead()

func _ready():
	set_max_health_gamestate()
	update_health_bar()

func _physics_process(delta):
	# Gravity things
	if not is_on_floor():
		velocity.y += gravity * delta

	# Character is in battle mode
	if GameState.on_tower:
		if current_battle_state == DungeonState.PRE_BATTLE:
			velocity.x = move_toward((0.5 * SPEED), 0, 12)
			move_and_slide()
		if go_forward:
			velocity.x = move_toward((0.5 * SPEED), 0, 12)
			move_and_slide()
		elif go_back:
			velocity.x = move_toward((-0.5 * SPEED), 0, 12)
			move_and_slide()
			
	# Character is attacking
	if did_attack:
		main_char.play("attack")
	
	# Character is moving
	if can_move :
		if (velocity.x > 1 || velocity.x < -1):
			main_char.animation = "running"
		else:
			main_char.animation = "default"

		if !GameState.on_tower:
			var direction = Input.get_axis("left", "right")
			if direction:
				velocity.x = direction * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, 12)

		move_and_slide()
		
		# When going back
		var isLeft = velocity.x < 0
		main_char.flip_h = isLeft
	
	# Character is idle
	else:
		velocity.x = 0
		main_char.animation = "default"

# When the mob attacked the character
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

# Player is attacking
func _on_attack():
	did_attack = true
	var damage = ceil((statsheet.STRENGTH * randi_range(0, (statsheet.STRENGTH/2))) + (statsheet.STRENGTH / 2))
	print("Player attacked with ", damage)
	$"../TurnManager".get_frontmost_mob().take_damage(damage)

# Player is defending
func _on_defend():
	did_defend = true
	defend = floor((statsheet.STRENGTH + statsheet.VITALITY) * 0.125)
	print("Player defended with ", defend)

# Player is healing
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
	
func _on_next_tower():
	current_battle_state = DungeonState.PRE_BATTLE
	go_forward = true
	
func _on_back_outside():
	current_battle_state = DungeonState.PRE_BATTLE
	go_back = true

# Helper functions
func turn_start():
	$ActionPanel.is_player_turn = true
	$ActionPanel.update_button_state()

func _on_turn_end():
	# Signal TurnManager to switch to enemy turn
	await get_tree().create_timer(0.55).timeout
	did_attack = false
	$"../TurnManager".start_next_turn()

func update_health_bar():
	health_bar.update_health(GameState.player_current_health, max_health)

func set_max_health_gamestate():
	max_health = statsheet.VITALITY
	GameState.player_max_health = max_health
	
	if GameState.player_current_health <= 0:
		GameState.player_current_health = GameState.player_max_health
