extends ColorRect
@export var time_frenzy: Node
@export var dayLength: float = 80.0
@export var nightLength: float = 30.0
@export var enemySpawnDelay: float = 2.0 

var isPaused: bool = false
var currentCycle: int = 0
var wasNight := false  # track previous state
var isNight := false
var timePassed: float = 0.0


@onready var timerLabel = $"../CanvasLayer/Time Freenzy"
#@
@onready var dark_overlay :  ColorRect = $"../CanvasLayer/DarkOverlay"

			
func adjustEnemySpawnSpeed(cycleNum: int):
	# Decrease spawn delay by 10% per cycle, never below 0.2s
	enemySpawnDelay = max(0.2, enemySpawnDelay * pow(0.9, cycleNum))
	print("Cycle ", cycleNum, " new spawn delay: ", enemySpawnDelay)
	
func _ready():
	print(dark_overlay)
	
func _process(delta):
	if isPaused:
		return
		
	timePassed += delta
	
	
	#Timer Display
	var minute  = int(timePassed) / 60
	var seconds = int(timePassed) % 60
	timerLabel.text = "Time: %d:%02d sec" % [minute,seconds]
		
	
	update_day_night()
	
func update_day_night():
	
	var cycle = dayLength + nightLength
	var cycleTime = fmod(timePassed, cycle)
	
	
	var isNightNow = cycleTime >= dayLength
	
	if isNightNow and not wasNight:
		currentCycle += 1
		adjustEnemySpawnSpeed(currentCycle)
		
	wasNight = isNightNow
	
	dayLength = max(80.0, dayLength * 0.95)
	nightLength = max(30.0, nightLength * 0.95)
	
		
	var c = dark_overlay.color
	c.a = lerp(c.a, 0.7 if isNightNow else 0.0, 0.05)
	dark_overlay.color = c
	timerLabel.modulate = Color.WHITE if isNightNow else Color.BLACK	
	


	
	
	
#func flash_red(baseColor):
	#var flash = abs(sin(Time.get_ticks_msec()* 0.001))
	
	#return Color(
		#baseColor.r,
		#baseColor.g * flash,
		#baseColor.b * flash
	#)
	
	
	
	
