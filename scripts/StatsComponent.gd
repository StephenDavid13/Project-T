extends Node2D
class_name StatsComponent

@export var NAME := 'Player'
@export var VITALITY : int = 100
@export var STRENGTH : int = 10
@export var INTELLIGENCE : int = 15
@export var SPEED : int = 50
@export var EXPERIENCE : int = 1000

func get_health():
	return VITALITY
