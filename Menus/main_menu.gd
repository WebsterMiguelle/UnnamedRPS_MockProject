extends Control

@onready var start_button: TextureButton = $MarginContainer/VBoxContainer/Separator2/start_button
@onready var start_game = preload("res://Scenes/Main.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_button.button_up.connect(_on_start_button_button_up)


func _on_start_button_button_up() -> void:
	get_tree().change_scene_to_packed(start_game)
