extends Camera2D

@export var decay = 0.9  # How quickly the shaking stops (0-1)
@export var max_offset = Vector2(5, 5)  # Max horizontal/vertical shake
@export var max_roll = 0.8  # Maximum rotation in radians
@export var target : Node2D  # The node the camera follows (e.g., player)

var trauma = 0  # Current shake strength
var trauma_power = 1  # Trauma exponent for better "feel"
var noise_y = 0

func _ready():
	randomize()
	noise_y = randi()

func add_trauma(amount):
	trauma = min(trauma + amount, 1.0)

func _process(delta):
	if target:
		global_position = target.global_position
	
	if trauma > 0:
		trauma = max(trauma - decay * delta, 0)
		shake()
	else:
		rotation = 0
		offset = Vector2.ZERO

func shake():
	var amount = pow(trauma, trauma_power)
	noise_y += 0
	# Using random noise for smoother shake
	rotation = max_roll * amount * randf_range(-1, 1)
	offset.x = max_offset.x * amount * randf_range(-1, 1)
	offset.y = max_offset.y * amount * randf_range(-1, 1)
