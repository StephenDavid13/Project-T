extends Node2D

@export var statsComponent : StatsComponent
@onready var timer = $Timer
@onready var animationAtk = $"../RigidBody2D/AnimatedSprite2D"

var dontAttackFirst := false
var rng_generator = RandomNumberGenerator.new()
var dmg := 0
var attacking := false

func _ready():
	var new_wait_time : float = 100/statsComponent.SPEED
	timer.wait_time = new_wait_time

# Do a single damage with modifier for monsters	
func damage():
	##dmg = (str * random number from 0 to (str/2)) + (str * 1.25) 
	attacking = true
	var dmg_modifier = statsComponent.STRENGTH / 2
	var dmg_modifier_rng = rng_generator.randi_range(0, dmg_modifier)
	dmg = ( statsComponent.STRENGTH * 1.25 ) * dmg_modifier_rng
	print(statsComponent.NAME + " attacked with " + str(dmg))
	animationAtk.play("attack")

# Timer that sets the speed of the monster
func _on_timer_timeout():
	if(dontAttackFirst) :
		damage()
	dontAttackFirst = true
	


func _on_animated_sprite_2d_animation_finished():
	animationAtk.play("default")
	
