extends Node2D
class_name StatsComponent

@export var NAME := 'Player'
@export var VITALITY := 100
@export var STRENGTH := 10
@export var INTELLIGENCE := 15
@export var SPEED := 50
@export var EXPERIENCE := 0

func get_health():
	return VITALITY
