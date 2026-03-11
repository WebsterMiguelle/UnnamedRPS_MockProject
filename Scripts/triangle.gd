extends Node2D

@export var type_name = "Triangle"
var speed := 0
var acceleration := 0
var decceleration := 0
var is_clashed := false

func setup(spd, acc, dec):
	speed = spd
	acceleration = acc
	decceleration = dec

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
