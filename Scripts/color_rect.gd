extends ColorRect

@export var totalTime: float = 60.0   # total seconds before full black
@export var darkTime: float = 15.0
var timePassed: float = 0.0

@onready var timerLabel = $"../CanvasLayer/Time Freenzy"

func _process(delta):
	timePassed += delta
	timePassed = min(timePassed,totalTime)
	
	var timeLeft = totalTime - timePassed
	var minute  = int(timeLeft) / 60
	var seconds = int(timeLeft) % 60
	timerLabel.text = "Time: %d:%02d sec" % [minute,seconds]
	
	
	var StartdarkTime = totalTime - darkTime
	var t := 0.0
	
	if timePassed > StartdarkTime:
		t = (timePassed - StartdarkTime) / darkTime
		
		timerLabel.modulate = Color.WHITE
		
	else:
		timerLabel.modulate = Color.BLACK
		
	t = clamp(t,0.0,1.0)
	
	# change color from white to black
	var baseColor = Color(1 - t, 1 - t, 1 - t)
	
	if timeLeft <= darkTime:
		baseColor = flash_red(baseColor)
		
	color = baseColor
	
func flash_red(baseColor):
	var flash = abs(sin(Time.get_ticks_msec()* 0.001))
	
	return Color(
		baseColor.r,
		baseColor.g * flash,
		baseColor.b * flash
	)
	
	
	
	
