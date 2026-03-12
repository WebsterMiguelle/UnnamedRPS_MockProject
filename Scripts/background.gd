extends Node2D

@onready var triangle_scene = preload("res://Scenes/triangle.tscn")
@onready var square_scene = preload("res://Scenes/square.tscn")
@onready var circle_scene = preload("res://Scenes/circle.tscn")
const MAIN_MENU = preload("uid://bv1etpv8opnuj")

@onready var game_over_screen = get_node("CanvasLayer/Game Over Screen")
@onready var score_label = $CanvasLayer2/Score
@onready var dark_overlay = $CanvasLayer/DarkOverlay
@onready var pause_screen = $"CanvasLayer/Pause Screen"

@onready var enemy_timer: Timer = $"Enemy Timer"
@onready var shake_camera: Camera2D = $ShakeCamera
@onready var clash_particles = preload("res://Scenes/clash_particles.tscn")
@onready var draw_particles = preload("res://Scenes/draw_particles.tscn")
@onready var h_box_container: HBoxContainer = $CanvasLayer/HBoxContainer
@onready var pattern: TextureRect = $ColorRect/Pattern
@onready var pause_button: TextureButton = $CanvasLayer/Pause_Button

@onready var background: ColorRect = $ColorRect
@onready var CLASH_particles: GPUParticles2D = $ColorRect/CLASH_particles

@export var player_speed := 300  
@export var player_acceleration := 20

@export var enemy_speed := 150 
@export var points_per_win: int = 100 
@export var initial_enemy_speed := 800:
	set(value):
		initial_enemy_speed = clamp(value,600,900)
@export var final_enemy_speed := 50:
	set(value):
		final_enemy_speed = clamp(value,50,200)
@export var enemy_decceleration := 20 
@export var enemy_spawn_rate := 3.0:
	set(value):
		enemy_spawn_rate = clamp(value,1.0,3.0)
		
var draw_words = [
	"Draw!",
	"Tie!",
	"LOL!",
	"REALLY!",
	"SERIOSLY!",
	"CUTE!",
	"IDIOT!"
]
var hype_words = [
	"Nice!",
	"Great!",
	"Awesome!",
	"Amazing!",
	"Excellent!",
	"Legendary!",
	"CLASH!"
]

var time_score_rate := 5  # points per second
var time_accumulator := 0.0
var combo: int = 0
var player_score: int = 0
var enemySpawnDelay: float = 2.0  # seconds between enemy spawns
var enemy_spawn_timer: float = 0.0

const PLAYER_LINE_Y = 400
const ENEMY_LINE_Y = 100

func get_hype_word():
	var index = clamp(min(combo / 5, hype_words.size() - 1),0,6)
	return hype_words[index]
	
func get_draw_word():
	return draw_words[randi() % draw_words.size()]
	
func spawn_score_popup(text, position, color := Color.WHITE):
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 15)
	label.modulate = Color.YELLOW
	label.position = position
	
	if combo < 5:
		label.modulate = Color.LIGHT_BLUE
	elif combo < 10:
		label.modulate = Color.MEDIUM_ORCHID
	elif combo < 15:
		label.modulate = Color.PINK
	elif combo < 20:
		label.modulate = Color.INDIAN_RED
	elif combo < 25:
		label.modulate = Color.ORANGE_RED
	elif combo < 30:
		label.modulate = Color.ORANGE
	else:
		label.modulate = Color.GOLD
	add_child(label)

	var tween = create_tween()
	tween.parallel().tween_property(label, "position:y", label.position.y - 80, 1.0)
	tween.parallel().tween_property(label, "modulate:a", 0, 1.0)
	tween.tween_callback(label.queue_free)
	
func spawn_clash_popup(text, color := Color.WHITE):
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 30)
	label.modulate = color
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.global_position = h_box_container.global_position
	label.position.y -= 100 
	
	

	add_child(label)
	slow_motion_effect(0.1,1)
	var tween = create_tween()
	tween.parallel().tween_property(label, "position:y", label.position.y - 240, 1.0)
	tween.parallel().tween_property(label, "modulate:a", 0, 1.0)
	tween.tween_callback(label.queue_free)

func slow_motion_effect(target:float,duration:float):
	#SLOW MOTION EFFECT
	var tween = create_tween()
	tween.tween_property(Engine, "time_scale", target, 0)
	tween.tween_property(Engine, "time_scale", 1, duration)
	
func _ready():
	#var node = get_node('')
	enemy_timer.wait_time = enemy_spawn_rate
	enemy_headstart()
	pause_screen.visible = false
	game_over_screen.visible = false
	background.color = Color.BLACK
	CLASH_particles.emitting = false
	
func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		get_tree().paused = !get_tree().paused
		pause_screen.visible = get_tree().paused
		print("Paused" if get_tree().paused else "Resumed")
		
func update_score_label():
	score_label.text = str(player_score)

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
	@warning_ignore("unused_variable")
	var button_pos = button_node.get_global_position()
	#shape.position = Vector2(get_viewport_rect().size.x / 2, PLAYER_LINE_Y)  # same Y for horizontal line
	var start_x = get_viewport_rect().size.x / 2
	var start_y = get_viewport_rect().size.y + 50  # bottom of screen
	shape.position = Vector2(start_x, start_y)
	if shape.has_method("setup"):
		shape.setup(player_speed, player_acceleration, 0)

	shape.add_to_group("players")
	add_child(shape)
	
	
			

func _process(delta):
	
	if get_tree().paused:
		return
	time_accumulator += delta
	if time_accumulator >= 1.0:
		var seconds_passed = int(time_accumulator)
	
	for player in get_tree().get_nodes_in_group("players"):
		if player.position.y > 0:
			player.speed += player.acceleration
		player.position.y -= player.speed * delta
		check_clash(player)
		if player.position.y < -50:
			player.queue_free()
				
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy.speed > final_enemy_speed:
			enemy.speed -= enemy.decceleration
		enemy.position.y += enemy.speed * delta
		if enemy.position.y > get_viewport_rect().size.y and enemy.is_clashed == false:
			show_game_over()
			return  
			

func spawn_enemy_top(value: int):
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

	var enemy = shape_scene.instantiate()
	if enemy.has_method("setup"):
		enemy.setup(initial_enemy_speed, 0, enemy_decceleration)
	enemy.add_to_group("enemies")
	enemy.position = Vector2(get_viewport_rect().size.x / 2, -50)
	enemy.scale.y = -1
	add_child(enemy)

func enemy_headstart():
	spawn_enemy_top(-1)
	await get_tree().create_timer(0.8).timeout
	spawn_enemy_top(-1)
	
	#var center_x = get_viewport_rect().size.x / 2
	#enemy.position = Vector2(center_x, ENEMY_LINE_Y)
	#enemy.position = Vector2(center_x, -50)
	
	


func check_clash(player_shape):
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if player_shape.global_position.distance_to(enemy.global_position) < 40 and player_shape.is_clashed == false:
			enemy.is_clashed = true
			player_shape.is_clashed = true
			resolve_rps(player_shape.type_name, enemy.type_name, player_shape.global_position)
			var shake_power = clamp(0.5 + combo * 0.1, 0.2, 0.8)
			shake_camera.add_trauma(shake_power)
			var tween = create_tween()
			tween.tween_property(Engine, "time_scale", 0.1, 0)
			tween.tween_property(Engine, "time_scale", 1, 0.1)
			
			# Throw shapes off screen
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


@warning_ignore("shadowed_variable_base_class")
func resolve_rps(player_type, enemy_type, position: Vector2 = Vector2(-1,-1)):
	if player_type == enemy_type:
		print("Draw!")
		combo = 0
		var tween = create_tween()
		tween.tween_property(background, "color", Color.BLACK, 0.2)
		CLASH_particles.emitting = false
		
		var particle = draw_particles.instantiate()
		particle.position = position
		add_child(particle)
		
		var draw_text = get_draw_word()
		spawn_score_popup(draw_text, position, Color.CYAN)
		
		
		update_score_label()
		
	elif (player_type == "Triangle" and enemy_type == "Square") or \
		 (player_type == "Square" and enemy_type == "Circle") or \
		 (player_type == "Circle" and enemy_type == "Triangle"):
		print("Player Wins!")
		if position != Vector2(-1,-1):
			var particle = clash_particles.instantiate()
			particle.position = position
			var particle_amount = clamp(10 + combo * 3,10,30)
			particle.amount = particle_amount
			
			add_child(particle)
			
		combo += 1
		var gained_points = points_per_win * combo
		player_score += gained_points
		update_score_label()
		
		var hype = get_hype_word()
		var popup_text = "%s x%d" % [hype, combo]
		
		if combo > 2:
			spawn_score_popup(popup_text, position)
		if combo == 10:
			spawn_clash_popup("SUPER CLASH!",Color.SKY_BLUE)
			var tween = create_tween()
			tween.tween_property(background, "color", Color("221a4a"), 0.2)
		elif combo == 20:
			spawn_clash_popup("MEGA CLASH!", Color.HOT_PINK)
			var tween = create_tween()
			tween.tween_property(background, "color", Color("6a2331"), 0.2)
		elif combo == 30:
			spawn_clash_popup("RPS CLASH!", Color.GOLDENROD)
			var tween = create_tween()
			tween.tween_property(background, "color", Color("7d3300"), 0.2)
			CLASH_particles.emitting = true
		
		var shake_power = clamp(0.5 + combo * 0.1, 0.5, 2.0)
		shake_camera.add_trauma(shake_power)
		
	else:
		print("Player Loses!")
		combo = 0
		show_game_over()

func _on_enemy_timer_timeout() -> void:
	var chance = randf()
	if chance <= 0.3:
		var rand = randi() % 3
		spawn_enemy_top(rand)
		await get_tree().create_timer(0.3).timeout
		spawn_enemy_top(rand)
		await get_tree().create_timer(0.3).timeout
		spawn_enemy_top(rand)
	else:
		spawn_enemy_top(-1)
		
func show_game_over():
	game_over_screen.visible = true
	await get_tree().process_frame
	get_tree().paused = true
		


func _on_retry_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_difficulty_timer_timeout() -> void:
	final_enemy_speed += 20
	enemy_spawn_rate -= 0.2
	enemy_timer.wait_time = enemy_spawn_rate
	initial_enemy_speed += 30
	print('DIFFICULTY UP!')


func _on_pause_button_pressed() -> void:
	get_tree().paused = !get_tree().paused
	pause_screen.visible = get_tree().paused
	pause_button.visible = false


func _unpause_button_pressed() -> void:
	get_tree().paused = !get_tree().paused
	pause_screen.visible = get_tree().paused
	pause_button.visible = true
	print("Paused" if get_tree().paused else "Resumed")


func _retry_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _back_main_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")
