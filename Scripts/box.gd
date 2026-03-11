extends Node2D

@onready var triangle_scene = preload("res://Triangle.tscn")
@onready var square_scene = preload("res://Square.tscn")
@onready var circle_scene = preload("res://Circle.tscn")

# Called when the node enters the scene tree for the first time.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_scissors_pressed():
	spawn_shape(triangle_scene, $"CanvasLayer/HBoxContainer/Scissors")


func _on_paper_pressed():
	spawn_shape(square_scene, $"CanvasLayer/HBoxContainer/Paper")


func _on_rock_pressed():
	spawn_shape(circle_scene, $"CanvasLayer/HBoxContainer/Rock")
	
	
	
func spawn_shape(shape_scene, button_node):
	var shape = shape_scene.instantiate()
	var button_pos = button_node.get_global_position()
	shape.position = button_pos + Vector2(0, -100)
	
	add_child(shape)
	
	
