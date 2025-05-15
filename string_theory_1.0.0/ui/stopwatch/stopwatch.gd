class_name Stopwatch extends Label

@onready var stopwatch_util: StopwatchUtil = $StopwatchUtil

func _process(_delta: float) -> void:
	var value := stopwatch_util.time()
	var mins := int(value / 60.0)
	var seconds :=  int( value - mins * 60 )
	var ms := int (( value * 1000.0 - mins * 60 * 1000 - seconds * 1000 ) / 10)
	#text = str( mins ) + ":" + str( seconds ) + "." + str (ms)
	text = "%02d:%02d:%002d"%[mins, seconds, (ms%100)]
