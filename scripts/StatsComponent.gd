extends Node2D
class_name StatsComponent

@export var NAME := 'Player'
@export var VITALITY := 100
@export var STRENGTH := 15
@export var INTELLIGENCE := 15
@export var SPEED := 10
@export var EXPERIENCE := 0

var health : float

func _ready():
	health = VITALITY
