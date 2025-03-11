extends Control

@onready var stopwatch: Stopwatch = $VBoxContainer/Stopwatch

@onready var start: Button = $VBoxContainer/HBoxContainer/Start
@onready var stop: Button = $VBoxContainer/HBoxContainer/Stop
@onready var pause: Button = $VBoxContainer/HBoxContainer/Pause
@onready var option_button: OptionButton = $VBoxContainer/HBoxContainer/OptionButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start.pressed.connect( func() -> void: stopwatch.start() )
	stop.pressed.connect( func() -> void: stopwatch.stop() )
	pause.pressed.connect( func() -> void: stopwatch.set_paused( not stopwatch.is_paused() ) )
	option_button.item_selected.connect( func(mode: int) -> void: stopwatch.timer_process_callback = mode )
