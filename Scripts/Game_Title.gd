extends TextureRect

func _ready():
	await get_tree().process_frame 
	
	# 2. Set the pivot to the center of the TextureRect
	pivot_offset = size / 2
	animate_logo()

func animate_logo():
	# Create a tween and set it to loop forever
	var tween = create_tween().set_loops()
	
	# 1. Expand (Scale up to 110%)
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.8)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	
	# 2. Shrink (Scale back to 100%)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.8)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
