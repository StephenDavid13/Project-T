extends Node2D

@export var statsComponent : StatsComponent
@onready var timer = $Timer

var dontAttackFirst = false
var rng_generator = RandomNumberGenerator.new()
var dmg := 0

func _ready():
	var new_wait_time : float = 100/statsComponent.SPEED
	timer.wait_time = new_wait_time
	
func damage():
	##dmg = (str * random number from 0 to (str/2)) + (str * 1.25) 
	var dmg_modifier = statsComponent.STRENGTH / 2
	var dmg_modifier_rng = rng_generator.randi_range(0, dmg_modifier)
	dmg = ( statsComponent.STRENGTH * 1.25 ) * dmg_modifier_rng
	print(statsComponent.NAME + " attacked with " + str(dmg))

func _on_timer_timeout():
	if(dontAttackFirst) :
		damage()
	dontAttackFirst = true
	
