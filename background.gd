extends Node2D

@onready var triangle_scene = preload("res://triangle.tscn")
@onready var square_scene = preload("res://square.tscn")
@onready var circle_scene = preload("res://circle.tscn")
@onready var game_over_screen = get_node("CanvasLayer/Game Over Screen")

const PLAYER_LINE_Y = 400
const ENEMY_LINE_Y = 100

@onready var score_label = $CanvasLayer2/Score
var player_score: int = 0
@export var points_per_win: int = 100 

func update_score_label():
	score_label.text = "Score: %d" % player_score

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
	shape.position = Vector2(get_viewport_rect().size.x / 2, PLAYER_LINE_Y)  # same Y for horizontal line
	shape.name = "Player"
	add_child(shape)
	
	var screen_size = get_viewport_rect().size
	
	var start_pos = Vector2(screen_size.x / 2, screen_size.y + 50)
	
	shape.global_position = start_pos
	animate_up(shape)
	
func _process(_delta):
	for player in get_children():
		if player.name == "Player":
			check_clash(player)


func animate_up(shape):
	var tween = create_tween()
	tween.tween_property(shape, "position:y", shape.position.y - 500, 0.5)
	tween.tween_property(shape, "position:y", shape.position.y - 50, 0.5)


func spawn_enemy_top():
	var rand = randi() % 3
	var shape_scene

	match rand:
		0: shape_scene = triangle_scene
		1: shape_scene = square_scene
		2: shape_scene = circle_scene

	var enemy = shape_scene.instantiate()
	enemy.name = "Enemy"  # mark it


	var center_x = get_viewport_rect().size.x / 2
	enemy.position = Vector2(center_x, ENEMY_LINE_Y)
	
	add_child(enemy)
	animate_enemy_down(enemy)


func animate_enemy_down(enemy):
	var tween = create_tween()
	tween.tween_property(enemy, "position:y",PLAYER_LINE_Y - 50, 3)  # moves downward in a line


func check_clash(player_shape):
	for enemy in get_children():
		if enemy.name == "Enemy" and player_shape.global_position.distance_to(enemy.global_position) < 40:
			resolve_rps(player_shape.type_name, enemy.type_name)
			enemy.queue_free()
			player_shape.queue_free()


func resolve_rps(player_type, enemy_type):
	if player_type == enemy_type:
		print("Draw!")
	elif (player_type == "Triangle" and enemy_type == "Square") or \
		 (player_type == "Square" and enemy_type == "Circle") or \
		 (player_type == "Circle" and enemy_type == "Triangle"):
		print("Player Wins!")
		player_score += points_per_win
		update_score_label()
	else:
		print("Player Loses!")
		show_game_over()


func _on_enemy_timer_timeout() -> void:
	spawn_enemy_top()
	
	
func show_game_over():
	game_over_screen.visible = true
	await get_tree().process_frame
	get_tree().paused = true
	
