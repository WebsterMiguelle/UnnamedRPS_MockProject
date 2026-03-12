extends Control

@onready var start_button: TextureButton = $MarginContainer/VBoxContainer/Separator2/start_button
@onready var start_game = preload("res://Scenes/Main.tscn")

func _ready() -> void:
	if not start_button.button_up.is_connected(_on_start_button_button_up):
		start_button.button_up.connect(_on_start_button_button_up)


func _on_start_button_button_up() -> void:
	get_tree().change_scene_to_packed(start_game)
	start_button.button_up.disconnect(_on_start_button_button_up)
 
