class_name Stopwatch extends Label

@export var autostart: bool = false
@export_enum("Idle", "Physics") var timer_process_callback := 0:
	set(value):
		if value == timer_process_callback:
			return
		
		if timer_process_callback == 1: # Physics
			if is_physics_processing_internal():
				set_physics_process_internal(false)
				set_process_internal(true)
		elif timer_process_callback == 0:
			if is_processing_internal():
				set_process_internal(false)
				set_physics_process_internal(true)
		
		timer_process_callback = value

var _processing := false
var _paused := false
var _accumulator := 0.0:
	set(value):
		_accumulator = value
		var mins := int(value / 60.0)
		var seconds :=  int( value - mins * 60 )
		var ms := int ( value * 1000.0 - mins * 60 * 1000 - seconds * 1000 ) / 10
		text = str( mins ) + ":" + str( seconds ) + "." + str (ms)

func start() -> void:
	if not is_inside_tree():
		printerr("Stopwatch was not added to the SceneTree. Either add it or set autostart to true.")
	_set_process(true)

func stop() -> void:
	_set_process(false)
	_accumulator = 0

func is_stopped() -> bool:
	return _processing

func set_paused(value: bool) -> void:
	if _paused == value:
		return
	_paused = value
	_set_process(_processing)

func is_paused() -> bool:
	return _paused

func _set_process(processing: bool):
	if timer_process_callback == 1: # Physics
		set_physics_process_internal( processing and not _paused )
	elif timer_process_callback == 0: # Internal
		set_process_internal( processing and not _paused )
	
	_processing = processing

func _ready() -> void:
	if autostart:
		start()
		autostart = false

func _process(delta: float) -> void:
	if not _processing or timer_process_callback == 1 or not is_processing_internal():
		return
	_accumulator += delta

func _physics_process(delta: float) -> void:
	if not _processing or timer_process_callback == 0 or not is_physics_processing_internal():
		return
	_accumulator += delta
