extends Control

@onready var timer_overcharged: Timer = $TimerOvercharged
@onready var stars_progress: StarsProgress = $StarsProgress
@onready var fuel_bar_rainbow: FuelBarRainbow = $FuelBarRainbow
@onready var speedometer_rainbow: SpeedometerRainbow = $SpeedometerRainbow
@onready var stopwatch: Stopwatch = $Stopwatch
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var dash_ui: Control = $DashUI


signal overcharged
signal no_energy

var player: Ship

var stars_trail: Array[Star]:
	set = set_stars_trail

func set_stars_trail(stars: Array[Star]) -> void:
	stars_trail = stars
	stars_progress.starCount = stars_trail.size()
	stars_progress.connectedStarCount = 0
	for idx in range(stars_trail.size()):
		if not stars_trail[idx].star_entered.is_connected(_on_star_entered_star_ui):
			# only connect unique stars
			stars_trail[idx].star_entered.connect(_on_star_entered_star_ui)

func _on_star_entered_star_ui() -> void:
	stars_progress.connectedStarCount += 1

func _ready() -> void:
	timer_overcharged.timeout.connect(_on_timer_overcharged_timeout)
	animation_player.play("stopwatch_grow")
	
func _process(_delta: float) -> void:
	if player.fuel <= 0:
		no_energy.emit()
	
	if player.fuel >= player.max_fuel and timer_overcharged.is_stopped():
		timer_overcharged.start()
		fuel_bar_rainbow.animation_player.play("full_energy")
#
	if 0 < player.fuel and player.fuel < player.max_fuel:
		if not timer_overcharged.is_stopped():
			timer_overcharged.stop()
			fuel_bar_rainbow.animation_player.stop()
	
	speedometer_rainbow.max_speed = player.max_speed_hud
	speedometer_rainbow.speed = player.speed
	fuel_bar_rainbow.max_fuel = player.max_fuel
	fuel_bar_rainbow.fuel = player.fuel

func texture_rect_tween(tex_rect: TextureRect) -> void:
	var tween := create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(tex_rect, "modulate", Color(255, 211, 0, 1) , 0.1)
	tween.parallel().tween_property(tex_rect, "scale", Vector2(1.2,1.2), 0.1)

func _on_timer_overcharged_timeout() -> void:
	fuel_bar_rainbow.animation_player.stop()
	overcharged.emit()
	set_process(false)

func stop_watch() -> void:
	animation_player.stop()
	stopwatch.set_process(false)

func do_dash_ui()-> void:
	dash_ui.dash_used()

func hide_dash_ui() -> void:
	dash_ui.hide()
