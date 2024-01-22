extends Node2D
class_name StatsComponent

@export var VITALITY := 100
@export var STRENGTH := 15
@export var INTELLIGENCE := 15

var health : float
var exp_gained : float

func _ready():
	health = VITALITY
	
func damage():
	##dmg = (str * random number from 0 to (str/2)) + (str * 1.25) 
	pass

