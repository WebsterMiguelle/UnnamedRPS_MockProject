extends Node2D

@onready var triangle_scene = preload("res://Scenes/triangle.tscn")
@onready var square_scene = preload("res://Scenes/square.tscn")
@onready var circle_scene = preload("res://Scenes/circle.tscn")
@onready var game_over_screen = get_node("CanvasLayer/Game Over Screen")
@onready var enemy_timer: Timer = $"Enemy Timer"
@onready var shake_camera: Camera2D = $ShakeCamera
@onready var clash_particles = preload("res://Scenes/clash_particles.tscn")
@onready var draw_particles = preload("res://Scenes/draw_particles.tscn")
const PLAYER_LINE_Y = 400
const ENEMY_LINE_Y = 100

@export var player_speed := 300 
@export var player_acceleration := 20

@export var initial_enemy_speed := 800:
	set(value):
		initial_enemy_speed = clamp(value,800,1600)
@export var final_enemy_speed := 50:
	set(value):
		final_enemy_speed = clamp(value,50,200)
@export var enemy_decceleration := 20 
@export var enemy_spawn_rate := 3.0:
	set(value):
		enemy_spawn_rate = clamp(value,1.0,3.0)

@onready var score_label = $CanvasLayer2/Score
var player_score: int = 0
@export var points_per_win: int = 100 

func _ready() -> void:
	var node = get_node('')
	enemy_timer.wait_time = enemy_spawn_rate
	enemy_headstart()

	
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
	
	#1. INSTANTIATE
	var shape = shape_scene.instantiate()
	
	
	#2. POSITIONING
	var button_pos = button_node.get_global_position()
	#shape.position = Vector2(get_viewport_rect().size.x / 2, PLAYER_LINE_Y)  # same Y for horizontal line
	var start_x = get_viewport_rect().size.x / 2
	var start_y = get_viewport_rect().size.y + 50  # bottom of screen
	shape.position = Vector2(start_x, start_y)
	
	#3. SETTING PARAMETERS
	shape.setup(player_speed,player_acceleration,0)
	
	#4. ADD CHILD
	shape.add_to_group("players")
	add_child(shape)
	#animate_up(shape)
	
func _process(delta):
	for player in get_tree().get_nodes_in_group("players"):
		if player.position.y < 600:
			player.speed += player.acceleration
		player.position.y -= player.speed * delta
		check_clash(player)
		if player.position.y < -50:  # off top of screen
			player.queue_free()
			
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.speed > final_enemy_speed:
			enemy.speed -= enemy.decceleration
		enemy.position.y += enemy.speed * delta  # move down
		if enemy.position.y > get_viewport_rect().size.y + 50:
			if enemy.is_clashed == false:
				show_game_over()  
			enemy.queue_free()

func animate_up(shape):
	var tween = create_tween()
	tween.tween_property(shape, "position:y", shape.position.y - 50, 0.5)
	

func spawn_enemy_top(value):
	#Value: if -1, default spawning, else, intentionally spawn desired shape at will
	
	#1. CHOOSE SHAPE
	var shape_scene
	
	if value == -1:
		var rand = randi() % 3
		match rand:
			0: shape_scene = triangle_scene
			1: shape_scene = square_scene
			2: shape_scene = circle_scene
	else:
		match value:
			0: shape_scene = triangle_scene
			1: shape_scene = square_scene
			2: shape_scene = circle_scene
	
	#2. INSTANTIATE
	var enemy = shape_scene.instantiate()
	enemy.add_to_group("enemies") 
	
	#3. POSITIONING
	var center_x = get_viewport_rect().size.x / 2
	#enemy.position = Vector2(center_x, ENEMY_LINE_Y)
	enemy.position = Vector2(center_x, -50)
	enemy.scale.y = -1
	
	#4. SETTING PARAMETERS
	enemy.setup(initial_enemy_speed,0,enemy_decceleration)
	
	#5. ADD CHILD
	enemy.add_to_group("enemies") 
	add_child(enemy)
	#animate_enemy_down(enemy)

func enemy_headstart(): #Start the Game with Enemy Advantage
	spawn_enemy_top(-1)
	await get_tree().create_timer(0.8).timeout
	spawn_enemy_top(-1)

func animate_enemy_down(enemy):
	var bottom_y = get_viewport_rect().size.y + 60
	var tween = create_tween()
	#tween.tween_property(enemy, "position:y",PLAYER_LINE_Y - 50, 3)  # moves downward in a line
	tween.tween_property(enemy, "position:y", bottom_y, 5)

func check_clash(player_shape):
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if player_shape.global_position.distance_to(enemy.global_position) < 40:
			
			
			#MARKED AS CLASHED
			enemy.is_clashed = true
			player_shape.is_clashed = true
			
			#CHECK RPS STATUS
			resolve_rps(player_shape.type_name, enemy.type_name, player_shape.global_position)
			
			#SHAKE EFFECT
			shake_camera.add_trauma(0.2)
			
			#SLOW MOTION EFFECT
			var tween = create_tween()
			tween.tween_property(Engine, "time_scale", 0.1, 0)
			tween.tween_property(Engine, "time_scale", 1, 0.1)
			
			#THROW SHAPES OFF-SCREEN
			var rotation_speed = randi_range(360,720)
			var y_offset = randi_range(-300,300)
			var x_target = get_viewport_rect().size.x + 200
			var x_target2 = get_viewport_rect().size.x - 1200
			
			
			var enemy_tween = create_tween()
			enemy_tween.parallel().tween_property(enemy, "position:x", x_target, 0.8)
			enemy_tween.parallel().tween_property(enemy, "position:y", enemy.position.y + y_offset, 0.8)
			enemy_tween.parallel().tween_property(enemy, "rotation_degrees", enemy.rotation_degrees + rotation_speed, 0.8)

			enemy_tween.tween_callback(enemy.queue_free)
			
			var player_tween = create_tween()
			player_tween.parallel().tween_property(player_shape, "position:x", x_target2, 0.8)
			player_tween.parallel().tween_property(player_shape, "position:y", player_shape.position.y + y_offset, 0.8)
			player_tween.parallel().tween_property(player_shape, "rotation_degrees", player_shape.rotation_degrees + rotation_speed, 0.8)

			player_tween.tween_callback(player_shape.queue_free)


func resolve_rps(player_type, enemy_type, position):
	if player_type == enemy_type:
		print("Draw!")
		
		#EMIT DRAW PARTICLE
		var particle = draw_particles.instantiate()
		particle.position =  position
		
		add_child(particle)
	elif (player_type == "Triangle" and enemy_type == "Square") or \
		 (player_type == "Square" and enemy_type == "Circle") or \
		 (player_type == "Circle" and enemy_type == "Triangle"):
		print("Player Wins!")
		
		#EMIT CLASH PARTICLE
		var particle = clash_particles.instantiate()
		particle.position =  position
		add_child(particle)
		player_score += points_per_win
		update_score_label()
		
	else:
		print("Player Loses!")
		show_game_over()


func _on_enemy_timer_timeout() -> void:
	var chance = randf()
	if chance <= 0.3: # 30% Chance to Spawn a Triplet
		var rand = randi() % 3
		spawn_enemy_top(rand)
		await get_tree().create_timer(0.3).timeout
		spawn_enemy_top(rand)
		await get_tree().create_timer(0.3).timeout
		spawn_enemy_top(rand)
	else: #70% Chance to Spawn a Randomized Projectile
		spawn_enemy_top(-1)
	
	
func show_game_over():
	game_over_screen.visible = true
	await get_tree().process_frame
	get_tree().paused = true
	
	
func _on_difficulty_timer_timeout() -> void:
	initial_enemy_speed += 25
	final_enemy_speed += 20
	enemy_spawn_rate -= 0.2
	enemy_timer.wait_time = enemy_spawn_rate
	print('Difficulty Up! Initial Enemy Speed: ' + str(initial_enemy_speed)
	 + ', Final Enemy Speed: ' + str(final_enemy_speed) + ', Spawn Rate: ' + str(enemy_spawn_rate))
	
