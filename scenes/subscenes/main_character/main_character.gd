extends CharacterBody2D

@onready var main_char = $AnimatedSprite2D
@onready var statsheet = $StatsComponent
@onready var player_hud = $CanvasLayer/PlayerHUD
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
var battle_log : Node

signal on_dead()

func _ready():
	GameState.main_char = self
	set_gamestate()
	update_health_bar()
	if GameState.on_tower:
		battle_log = $"../Control/Panel/BattleLog"

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

# START OF THINGS CHARACTER CAN DO WHILE BATTLING
func _on_attack(mob : String):
	did_attack = true
	var get_mob = $"../TurnManager".get_target_mob(mob)
	var multiplier = rng_generator.randf_range(0, 2)
	var damage = int((GameState.player_strength + rng_generator.randi_range(1, statsheet.STRENGTH / 2)) * multiplier)
	if damage == 0:
		log_message("MISSED!")
	elif multiplier >= 1.8:
		log_message("CRIT! Attacked with %d" % damage)
	else:
		log_message("%s attacked with %d to %s" % [GameState.player_name, damage, get_mob.mob_name])

	get_mob.take_damage(damage)

func _on_defend():
	did_defend = true
	defend = int((GameState.player_strength + GameState.player_vitality) * 0.05)
	log_message("%s defended with %d" % [GameState.player_name, defend])

func _on_heal():
	did_heal = true
	var heal = int(GameState.player_intelligence * rng_generator.randf_range(0.75, 1.5))
	GameState.player_current_health = min(GameState.player_current_health + heal, GameState.player_max_health)
	log_message("%s healed with %d" % [GameState.player_name, heal])
	update_health_bar()
	
func take_damage(mob_name: String, damage: int):
	var final_damage = damage
	if damage == 0:
		log_message("%s missed!" % mob_name)
	else:
		if did_defend:
			final_damage -= defend
			did_defend = false
			defend = 0
			if final_damage <= 0:
				final_damage = 0
				log_message("FULLY DEFENDED! %s didn't damage you." % mob_name)
			else:
				GameState.player_current_health -= final_damage
				log_message("%s dealt %d damage" % [mob_name, final_damage])
		else:
			GameState.player_current_health -= final_damage
			log_message("%s dealt %d damage" % [mob_name, final_damage])

		if GameState.player_current_health <= 0:
			GameState.player_current_health = 0
			emit_signal("on_dead")
			update_health_bar()

	update_health_bar()
# END OF THINGS CHARACTER CAN DO WHILE BATTLING
	
# START FUNCTIONS FOR MOVEMENT
func handle_battle_movement():
	if GameState.on_tower:
		if current_battle_state == GameState.DungeonState.PRE_BATTLE and not go_back:
			main_char.animation = "running"
			velocity.x = move_toward(1 * SPEED, 0, 12)
		elif go_forward:
			main_char.animation = "running"
			velocity.x = move_toward(1 * (SPEED * 8), 0, 12)
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

func _on_next_tower():
	current_battle_state = GameState.DungeonState.PRE_BATTLE
	go_forward = true

func _on_back_outside():
	current_battle_state = GameState.DungeonState.PRE_BATTLE
	go_back = true
# END FUNCTIONS FOR MOVEMENT

# START OF HELPER FUNCTIONS FOR TURN BASED MOVEMENT
func turn_start():
	$ActionPanel.is_player_turn = true
	$ActionPanel.update_button_state()

func _on_turn_end():
	await get_tree().create_timer(0.57).timeout
	did_attack = false
	$"../TurnManager".start_next_turn()
# END OF HELPER FUNCTIONS FOR TURN BASED MOVEMENT

# START OF OTHER HELPER FUNCTIONS
func update_health_bar():
	player_hud.update_health(GameState.player_current_health, GameState.player_max_health)

func update_exp():
	player_hud.update_exp("Velices: %s" % GameState.player_exp)

func set_gamestate():
	if not GameState.is_initialized:
		GameState.is_initialized = true
		max_health = statsheet.VITALITY
		GameState.player_max_health = max_health
		GameState.player_current_health = max_health
		GameState.player_exp = statsheet.EXPERIENCE
		
		GameState.highest_tower_level = 1

		GameState.raw_player_strength = statsheet.STRENGTH
		GameState.raw_player_vitality = statsheet.VITALITY
		GameState.raw_player_intelligence = statsheet.INTELLIGENCE
		GameState.raw_player_speed = statsheet.SPEED
		
		GameState.player_strength = statsheet.STRENGTH
		GameState.player_vitality = statsheet.VITALITY
		GameState.player_intelligence = statsheet.INTELLIGENCE
		GameState.player_speed = statsheet.SPEED
		
		GameState.currency_water = 0
		GameState.currency_earth = 0
		GameState.currency_fire = 0
		GameState.currency_wind = 0
		
		GameState.water_imbued = 1
		GameState.earth_imbued = 1
		GameState.fire_imbued = 1
		GameState.wind_imbued = 1
		
		GameState.mod_slots = 0
		GameState.all_mods_label = ["--- Empty Mod ---", "--- Empty Mod ---", "--- Empty Mod ---", "--- Empty Mod ---"]
		GameState.all_mods_percentage = []
		GameState.all_mods_text = []
		
		if GameState.player_current_health <= 0:
			GameState.player_current_health = GameState.player_max_health
			
	player_hud.player_name.text = GameState.player_name
	update_exp()

func log_message(message: String):
	if battle_log:
		battle_log.update_message(message)

