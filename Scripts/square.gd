extends Node2D

@export var type_name = "Square"
var speed := 0
var acceleration := 0
var decceleration := 0
var is_clashed := false

func setup(spd, acc, dec):
	speed = spd
	acceleration = acc
	decceleration = dec
	
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
