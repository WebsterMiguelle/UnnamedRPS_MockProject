extends Node2D

@onready var triangle_scene = preload("res://Scenes/triangle.tscn")
@onready var square_scene = preload("res://Scenes/square.tscn")
@onready var circle_scene = preload("res://Scenes/circle.tscn")
const MAIN_MENU = preload("uid://bv1etpv8opnuj")

	
@onready var game_over_screen = get_node("CanvasLayer/Game Over Screen2")
@onready var score_label = $CanvasLayer2/Score
@onready var dark_overlay = $CanvasLayer/DarkOverlay
@onready var pause_screen = $"CanvasLayer/Pause Screen"

@onready var timeLabel = $"CanvasLayer2/TimeLabel"
@onready var comboLabel = $"CanvasLayer2/ComboLabel"

@onready var difficulty_timer: Timer = $DifficultyTimer
@onready var enemy_timer: Timer = $"Enemy Timer"
@onready var shake_camera: Camera2D = $ShakeCamera
@onready var clash_particles = preload("res://Scenes/clash_particles.tscn")
@onready var draw_particles = preload("res://Scenes/draw_particles.tscn")
@onready var h_box_container: HBoxContainer = $CanvasLayer/HBoxContainer
@onready var pattern: TextureRect = $ColorRect/Pattern
@onready var pause_button: TextureButton = $CanvasLayer/Pause_Button

@onready var background: ColorRect = $ColorRect
@onready var CLASH_particles: GPUParticles2D = $ColorRect/CLASH_particles

@onready var sfx_player: AudioStreamPlayer2D = $"SFX Player"
var playback: AudioStreamPlaybackPolyphonic
const BUTTON = preload("uid://dbfmq2oucugf7")
const CLASH = preload("uid://bx4sjsu5b86xu")
const DRAW = preload("uid://7wchsd46l0mb")
const LOSE_COUNTER = preload("uid://cjilfol4gvosx")
const PAPER_COUNTER = preload("uid://djlyvcjvdvl7b")
const ROCK_COUNTER = preload("uid://cm3paivwl2rrm")
const SCISSOR_COUNTER = preload("uid://c875dj5f4v8pp")
const CLASH_CHEER = preload("uid://deyrr25vfblh7")
const SUPER_CLASH = preload("uid://cnotsb71flbsn")
const MEGA_CLASH = preload("uid://d24fw1joefwbj")
const RPS_CLASH = preload("uid://dc7l11blghllo")
const COMBO_1 = preload("uid://b80bmfn1uatew")
const COMBO_2 = preload("uid://cpqd2sim8muhb")
const COMBO_3 = preload("uid://bqax6j8r0udqy")
const COMBO_4 = preload("uid://c44ij65op8jfa")
const COMBO_5 = preload("uid://d3appgpdq4f8w")
const COMBO_6 = preload("uid://cj28v687j38g8")
const COMBO_7 = preload("uid://sb8p46n1qxl0")
const COMBO_DOWN = preload("uid://bgup1ufpobo7w")

@onready var bgm_player: AudioStreamPlayer2D = $"BGM Player"
var synchronizer: AudioStreamSynchronized

@export var player_speed := 300  
@export var player_acceleration := 200

@export var enemy_speed := 150 
@export var points_per_win: int = 100 
@export var score_multiplier: int = 1
@export var initial_enemy_speed := 800:
	set(value):
		initial_enemy_speed = clamp(value,600,900)
@export var final_enemy_speed := 50:
	set(value):
		final_enemy_speed = clamp(value,50,400)
@export var enemy_decceleration := 20 
@export var enemy_spawn_rate := 3.0:
	set(value):
		enemy_spawn_rate = clamp(value,0.6,3.0)
		
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

var is_paused: bool = false
var time_score_rate := 5  # points per second
var time_accumulator := 0.0
var combo: int = 0
var highest_combo: int = 0
var total_time: float = 0.0  # 
var player_score: int = 0
var enemySpawnDelay: float = 2.0  # seconds between enemy spawns
var enemy_spawn_timer: float = 0.0

const PLAYER_LINE_Y = 400
const ENEMY_LINE_Y = 100

func get_hype_word():
	var index = clamp(min(combo / 10, hype_words.size() - 1),0,6)
	return hype_words[index]
	
func get_draw_word():
	return draw_words[randi() % draw_words.size()]
	
func spawn_score_popup(text, position, color := Color.WHITE):
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 15)
	label.modulate = Color.YELLOW
	label.position = position
	
	if combo < 10:
		label.modulate = Color.LIGHT_BLUE
		play_sound(COMBO_1)
	elif combo < 20:
		label.modulate = Color.MEDIUM_ORCHID
		play_sound(COMBO_2)
	elif combo < 30:
		label.modulate = Color.PINK
		play_sound(COMBO_3)
	elif combo < 40:
		label.modulate = Color.INDIAN_RED
		play_sound(COMBO_4)
	elif combo < 50:
		label.modulate = Color.ORANGE_RED
		play_sound(COMBO_5)
	elif combo < 60:
		label.modulate = Color.ORANGE
		play_sound(COMBO_6)
	else:
		label.modulate = Color.GOLD
		play_sound(COMBO_7)
	add_child(label)

	var tween = create_tween()
	tween.parallel().tween_property(label, "position:y", label.position.y - 80, 1.0)
	tween.parallel().tween_property(label, "modulate:a", 0, 1.0)
	tween.tween_callback(label.queue_free)
	
func spawn_clash_popup(text, color := Color.WHITE):
	var label = Label.new()
	label.text = text + ' ' + str(score_multiplier) + 'x'
	label.add_theme_font_size_override("font_size", 27)
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
	
	pause_screen.visible = false
	#pause_button.visible = true
	
	pause_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	#pause_button.process_mode = Node.PROCESS_MODE_ALWAYS
	game_over_screen.process_mode = Node.PROCESS_MODE_ALWAYS

	
	#var node = get_node('')
	enemy_timer.wait_time = enemy_spawn_rate
	enemy_headstart()
	pause_screen.visible = false
	game_over_screen.visible = false
	background.color = Color.BLACK
	CLASH_particles.emitting = false
	playback = sfx_player.get_stream_playback()
	synchronizer = bgm_player.stream
	synchronizer.set_sync_stream_volume(1, -60)
	synchronizer.set_sync_stream_volume(2, -60)
	synchronizer.set_sync_stream_volume(3, -60)
	Engine.time_scale = 1.0
	score_multiplier = 1
	

func play_sound(stream: AudioStream):
	if !sfx_player.playing:
		sfx_player.play()
		playback = sfx_player.get_stream_playback()

	playback.play_stream(stream)

func _input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		get_tree().paused = !get_tree().paused
		pause_screen.visible = get_tree().paused
		enemy_timer.paused = !enemy_timer.paused
		difficulty_timer.paused = !difficulty_timer.paused
		print("Paused" if get_tree().paused else "Resumed")

	
#	if not pause_button.is_connected("pressed", Callable(self, "_on_paused_button_pressed")):
	#	pause_button.connect("pressed", Callable(self, "_on_paused_button_pressed"))
	
	print(timeLabel)
	print(comboLabel)
	#timeLabel.add_theme_font_size_override("font_size", 20)
	#comboLabel.add_theme_font_size_override("font_size", 20)
	
	
func update_score_label():
	score_label.text = str(player_score)

func _on_scissors_pressed():
	play_sound(BUTTON)
	print("Spawning Triangle")
	spawn_shape(triangle_scene, $"CanvasLayer/HBoxContainer/Scissors")

func _on_paper_pressed():
	print("Spawning Paper")
	play_sound(BUTTON)
	spawn_shape(square_scene, $"CanvasLayer/HBoxContainer/Paper")

func _on_rock_pressed():
	print("Spawning Rock")
	play_sound(BUTTON)
	print(sfx_player.playing)
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
	total_time = time_accumulator
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
			var shake_power = clamp(score_multiplier * 0.1, 0.2, 0.6)
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
		if combo >= 30: 
			play_sound(COMBO_DOWN)
			slow_motion_effect(0.1,1)
			final_enemy_speed -= 60
			enemy_spawn_rate += 0.4
			enemy_timer.wait_time = enemy_spawn_rate
			initial_enemy_speed -= 60
		print("Draw!")
		combo = 0
		score_multiplier = 1
		play_sound(DRAW)
		synchronizer.set_sync_stream_volume(1, -60)
		synchronizer.set_sync_stream_volume(2, -60)
		synchronizer.set_sync_stream_volume(3, -60)
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
		if combo > highest_combo:
			highest_combo = combo
			
		
		var hype = get_hype_word()
		var popup_text = "%s x%d" % [hype, combo]
		
		if(player_type == "Triangle"): play_sound(SCISSOR_COUNTER)
		if(player_type == "Square"): play_sound(PAPER_COUNTER)
		if(player_type == "Circle"): play_sound(ROCK_COUNTER)
		
		if combo > 2:
			spawn_score_popup(popup_text, position)
		if combo == 10:
			score_multiplier += 1
			play_sound(CLASH)
			play_sound(SUPER_CLASH)
			var bgm_tween = create_tween()
			bgm_tween.tween_method(
				func(volume): synchronizer.set_sync_stream_volume(1, 0),
				-60.0,
				0.0,
				1.0
			)
			spawn_clash_popup("SUPER CLASH!",Color.SKY_BLUE)
			var tween = create_tween()
			tween.tween_property(background, "color", Color("221a4a"), 0.2)
		elif combo == 20:
			score_multiplier += 1
			play_sound(CLASH)
			play_sound(MEGA_CLASH)
			var bgm_tween = create_tween()
			bgm_tween.tween_method(
				func(volume): synchronizer.set_sync_stream_volume(2, 0),
				-60.0,
				0.0,
				1.0
			)
			
			spawn_clash_popup("MEGA CLASH!", Color.HOT_PINK)
			var tween = create_tween()
			tween.tween_property(background, "color", Color("6a2331"), 0.2)
		elif combo % 30 == 0:
			score_multiplier += 1
			var bgm_tween = create_tween()
			bgm_tween.tween_method(
				func(volume): synchronizer.set_sync_stream_volume(3, 0),
				-60.0,
				0.0,
				1.0
			)
			play_sound(CLASH)
			play_sound(RPS_CLASH)
			play_sound(CLASH_CHEER)
			spawn_clash_popup("RPS CLASH!", Color.GOLDENROD)
			var tween = create_tween()
			tween.tween_property(background, "color", Color("7d3300"), 0.2)
			CLASH_particles.emitting = true
		
		var shake_power = clamp(score_multiplier * 0.1, 0.1, 0.5)
		shake_camera.add_trauma(shake_power)
		
		var gained_points = points_per_win * score_multiplier
		player_score += gained_points
		update_score_label()
	else:
		print("Player Loses!")
		combo = 0
		show_game_over()

func _on_enemy_timer_timeout() -> void:
	var chance = randf()
	if chance <= 0.3 and final_enemy_speed < 300:
		var rand = randi() % 3
		spawn_enemy_top(rand)
		await get_tree().create_timer(0.1).timeout
		spawn_enemy_top(rand)
		await get_tree().create_timer(0.1).timeout
		spawn_enemy_top(rand)
	else:
		spawn_enemy_top(-1)
		
func show_game_over():
	play_sound(LOSE_COUNTER)
	bgm_player.stop()
	game_over_screen.visible = true
	
	timeLabel.text = str("Time: %s" % format_time(total_time))
	comboLabel.text = str("Highest Combo: %d" % highest_combo)
	
	await get_tree().process_frame
	get_tree().paused = true
	
func format_time(seconds: float) -> String:
	var mins = int(seconds) / 60
	var secs = int(seconds) % 60
	return "%02d:%02d" % [mins, secs]

func _on_retry_pressed() -> void:
	play_sound(BUTTON)
	await get_tree().create_timer(0.2).timeout
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_difficulty_timer_timeout() -> void:
	final_enemy_speed += 30
	enemy_spawn_rate -= 0.2
	enemy_timer.wait_time = enemy_spawn_rate
	initial_enemy_speed += 30
	print('DIFFICULTY UP!')


func _on_pause_button_pressed() -> void:
	play_sound(BUTTON)
	get_tree().paused = !get_tree().paused
	pause_screen.visible = get_tree().paused
	pause_button.visible = false
	enemy_timer.paused = true
	difficulty_timer.paused = true


func _unpause_button_pressed() -> void:
	play_sound(BUTTON)
	get_tree().paused = !get_tree().paused
	pause_screen.visible = get_tree().paused
	pause_button.visible = true
	print("Paused" if get_tree().paused else "Resumed")
	enemy_timer.paused = false
	difficulty_timer.paused = false


func _retry_button_pressed() -> void:
	play_sound(BUTTON)
	await get_tree().create_timer(0.2).timeout
	get_tree().paused = false
	get_tree().reload_current_scene()


func _back_main_menu_button_pressed() -> void:
	play_sound(BUTTON)
	await get_tree().create_timer(0.2).timeout
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")
