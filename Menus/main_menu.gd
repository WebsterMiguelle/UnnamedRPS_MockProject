extends Control

@onready var start_button: TextureButton = $start_button
@onready var start_game = preload("res://Scenes/Main.tscn")
@onready var button_sfx: AudioStreamPlayer2D = $Button_SFX
@onready var transition_sfx: AudioStreamPlayer2D = $Transition_SFX

func _ready() -> void:
	if not start_button.button_up.is_connected(_on_start_button_button_up):
		start_button.button_up.connect(_on_start_button_button_up)


func _on_start_button_button_up() -> void:
	transition_sfx.play()
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_packed(start_game)
	start_button.button_up.disconnect(_on_start_button_button_up)
 
