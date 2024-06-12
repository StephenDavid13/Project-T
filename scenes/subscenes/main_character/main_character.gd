extends CharacterBody2D

@onready var main_char = $AnimatedSprite2D
@onready var statsheet = $StatsComponent
@onready var health_bar = $HealthBar
@onready var battle_log = $"../Control/BattleLog"

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var rng_generator = RandomNumberGenerator.new()
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var current_battle_state = GameState.DungeonState.PRE_BATTLE

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
	GameState.main_char = self
	set_gamestate()
	update_health_bar()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if did_attack:
		main_char.play("attack")
	else:
		handle_battle_movement()
		handle_animation()
		handle_free_movement()
		move_and_slide()
		update_direction()

func handle_battle_movement():
	if GameState.on_tower:
		if current_battle_state == GameState.DungeonState.PRE_BATTLE and not go_back:
			main_char.animation = "running"
			velocity.x = move_toward(1 * SPEED, 0, 12)
		elif go_forward:
			main_char.animation = "running"
			velocity.x = move_toward(1 * SPEED, 0, 12)
		elif go_back:
			main_char.animation = "running"
			velocity.x = move_toward(-1 * SPEED, 0, 12)
		else:
			main_char.animation = "default"
			velocity.x = 0

func handle_animation():
	if can_move:
		if abs(velocity.x) > 1:
			main_char.animation = "running"
		else:
			main_char.animation = "default"

func handle_free_movement():
	if not GameState.on_tower and can_move:
		var direction = Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, 12)

func update_direction():
	main_char.flip_h = velocity.x < 0

func take_damage(damage: int):
	var final_damage = damage
	if damage == 0:
		log_message("Monster missed!")
	else:
		if did_defend:
			final_damage -= defend
			did_defend = false
			defend = 0
			if final_damage <= 0:
				final_damage = 0
				log_message("FULLY DEFENDED! Monster didn't damage you.")
			else:
				GameState.player_current_health -= final_damage
				log_message("Monster dealt %d damage" % final_damage)
		else:
			GameState.player_current_health -= final_damage
			log_message("Monster dealt %d damage" % final_damage)

		if GameState.player_current_health <= 0:
			GameState.player_current_health = 0
			emit_signal("on_dead")
			update_health_bar()

	update_health_bar()

func _on_attack():
	did_attack = true
	var multiplier = rng_generator.randf_range(0, 2)
	var damage = int((GameState.player_strength + rng_generator.randi_range(1, statsheet.STRENGTH / 2)) * multiplier)
	if multiplier == 0.0:
		log_message("MISSED! Player attacked with %d" % damage)
	elif multiplier >= 1.5:
		log_message("CRIT! Player attacked with %d" % damage)
	else:
		log_message("Player attacked with %d" % damage)

	$"../TurnManager".get_frontmost_mob().take_damage(damage)

func _on_defend():
	did_defend = true
	defend = int((GameState.player_strength + GameState.player_vitality) * 0.05)
	log_message("Player defended with %d" % defend)

func _on_heal():
	did_heal = true
	var heal = int(GameState.player_intelligence * rng_generator.randf_range(0.75, 1.5))
	GameState.player_current_health = min(GameState.player_current_health + heal, GameState.player_max_health)
	log_message("Player healed with %d" % heal)
	update_health_bar()

func _on_next_tower():
	current_battle_state = GameState.DungeonState.PRE_BATTLE
	go_forward = true

func _on_back_outside():
	current_battle_state = GameState.DungeonState.PRE_BATTLE
	go_back = true

func turn_start():
	$ActionPanel.is_player_turn = true
	$ActionPanel.update_button_state()

func _on_turn_end():
	await get_tree().create_timer(0.55).timeout
	did_attack = false
	$"../TurnManager".start_next_turn()

func update_health_bar():
	health_bar.update_health(GameState.player_current_health, GameState.player_max_health)

func set_gamestate():
	if not GameState.is_initialized:
		GameState.is_initialized = true
		max_health = statsheet.VITALITY
		GameState.player_max_health = max_health
		GameState.player_exp = statsheet.EXPERIENCE

		GameState.player_strength = statsheet.STRENGTH
		GameState.player_vitality = statsheet.VITALITY
		GameState.player_intelligence = statsheet.INTELLIGENCE
		GameState.player_speed = statsheet.SPEED

		if GameState.player_current_health <= 0:
			GameState.player_current_health = GameState.player_max_health

func log_message(message: String):
	if battle_log:
		battle_log.update_message(message)

