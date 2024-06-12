extends CharacterBody2D

@onready var main_char = $AnimatedSprite2D
@onready var statsheet = $StatsComponent
@onready var health_bar = $HealthBar

# Random stuff
var battle_log
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var rng_generator = RandomNumberGenerator.new()
const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var current_battle_state = GameState.DungeonState.PRE_BATTLE

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
	GameState.main_char = self
	set_gamestate()
	update_health_bar()
	
	if GameState.on_tower:
		battle_log = $"../Control/BattleLog"

func _physics_process(delta):
	# Gravity things
	if not is_on_floor():
		velocity.y += gravity * delta

	# Character is in battle mode
	if GameState.on_tower:
		if current_battle_state == GameState.DungeonState.PRE_BATTLE:
			velocity.x = move_toward((0.5 * SPEED), 0, 12)
			move_and_slide()
		if go_forward:
			velocity.x = move_toward((0.8 * SPEED), 0, 12)
			move_and_slide()
		elif go_back:
			velocity.x = move_toward((-0.8 * SPEED), 0, 12)
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
	if damage == 0:
		battle_log.update_message("Monster missed!")
	else:
		if did_defend:
			final_damage -= defend
			did_defend = false
			defend = 0
			if final_damage <= 0:
				final_damage = 0
				battle_log.update_message("FULLY DEFENDED! Monster didn't damage you.")
			else:
				GameState.player_current_health -= final_damage
				battle_log.update_message("Monster damage with %d" % [final_damage])
		else:
			GameState.player_current_health -= final_damage
			battle_log.update_message("Monster damage with %d" % [final_damage])
		if GameState.player_current_health <= 0:
			GameState.player_current_health = GameState.player_max_health
			update_health_bar()
			on_dead.emit()
	update_health_bar()

# Player is attacking
func _on_attack():
	did_attack = true
	var multiplier = randf_range(0, 2)	
	var damage = floor((GameState.player_strength + randi_range(1, statsheet.STRENGTH / 2)) * multiplier)
	if multiplier == 0.0:
		battle_log.update_message("MISSED! Player attacked with %d" % [damage])
	if multiplier >= 1.5:
		battle_log.update_message("CRIT! Player attacked with %d" % [damage])
	else:
		battle_log.update_message("Player attacked with %d" % [damage])
	$"../TurnManager".get_frontmost_mob().take_damage(damage)

# Player is defending
func _on_defend():
	did_defend = true
	defend = floor((GameState.player_strength + GameState.player_vitality) * 0.05)
	battle_log.update_message("Player defended with %d" % [defend])

# Player is healing
func _on_heal():
	did_heal = true
	var heal = floor(GameState.player_intelligence * randf_range(0.75, 1.5))
	var new_health = GameState.player_current_health + heal
	if new_health >= GameState.player_max_health:
		GameState.player_current_health = GameState.player_max_health
	else:
		GameState.player_current_health += heal
	battle_log.update_message("Player healed with %d" % [heal])
	update_health_bar()
	
func _on_next_tower():
	current_battle_state = GameState.DungeonState.PRE_BATTLE
	go_forward = true
	
func _on_back_outside():
	current_battle_state = GameState.DungeonState.PRE_BATTLE
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
	health_bar.update_health(GameState.player_current_health, GameState.player_max_health)

func set_gamestate():
	if !GameState.is_initialized:
		GameState.is_initialized = true
		max_health = statsheet.VITALITY
		GameState.player_max_health = max_health
		GameState.player_exp = statsheet.EXPERIENCE
		
		# Place stats in GameState
		GameState.player_strength = statsheet.STRENGTH
		GameState.player_vitality = statsheet.VITALITY
		GameState.player_intelligence = statsheet.INTELLIGENCE
		GameState.player_speed = statsheet.SPEED
		
		if GameState.player_current_health <= 0:
			GameState.player_current_health = GameState.player_max_health
