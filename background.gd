extends Node2D

@onready var triangle_scene = preload("Triangle.tscn")
@onready var square_scene = preload("Square.tscn")
@onready var circle_scene = preload("Circle.tscn")

# Called when the node enters the scene tree for the first time.
	



func _on_scissors_pressed():
	print("Spawning Triangle")
	spawn_shape(triangle_scene, $"CanvasLayer/HBoxContainer/Scissors")


func _on_paper_pressed():
	print("Spawning Paper")
	spawn_shape(square_scene, $"CanvasLayer/HBoxContainer/Paper")


func _on_rock_pressed():
	print("Spawning Rock")
	spawn_shape(circle_scene, $"CanvasLayer/HBoxContainer/Rock")
	
	
	
func spawn_shape(shape_scene, button_node):
	
	var shape = shape_scene.instantiate()
	var button_pos = button_node.get_global_position()
	shape.position = button_pos + Vector2(400, 300)
	
	add_child(shape)
	animate_up(shape)
	
func animate_up(shape):
	var tween = create_tween()
	tween.tween_property(shape, "position:y", shape.position.y - 150, 0.5)
	
	
