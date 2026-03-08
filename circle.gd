extends Area2D

@export var type_name: String = "Circle"

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if self.name == "Player" and area.name == "Enemy":

		if get_parent().has_method("resolve_rps"):
			get_parent().resolve_rps(self, area)
