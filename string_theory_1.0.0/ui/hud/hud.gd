extends Control

@onready var timer_overcharged: Timer = $TimerOvercharged
@onready var stars_progress: StarsProgress = $StarsProgress
@onready var speed_and_energy: Gauge = $SpeedAndEnergy

@export var fuel_fill_rate : Curve
@export var fuel_burn_rate : Curve
@export var max_fuel:= 5.0
var fuel := 2.5

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

func _process(_delta: float) -> void:
	var ship_speed : int = clamp(player.speed, 0, player.max_speed_hud)
	speed_and_energy.main_gauge_label_value = snapped(ship_speed,20)
	speed_and_energy.main_charge = ship_speed / player.max_speed

	# Decrease energy level
	if player and player.current_state == Ship.States.FLY:
		fuel = max ( fuel -  2.0 * fuel_burn_rate.sample( 1.0 - fuel / max_fuel ) * _delta, 0 )

	if fuel <= 0:
		no_energy.emit()
		speed_and_energy.animation_player.play("empty_charge")
	
	if fuel >= max_fuel and timer_overcharged.is_stopped():
		timer_overcharged.start()
		speed_and_energy.animation_player.play("full_charge")

	if 0 < fuel and fuel < max_fuel:
		if not timer_overcharged.is_stopped():
			timer_overcharged.stop()
			speed_and_energy.animation_player.stop()
		if speed_and_energy.animation_player.current_animation == "empty_charge":
			speed_and_energy.animation_player.stop()

	# Increase energy level
	if player.current_state == player.States.ORBIT:
		fuel = min(fuel + fuel_fill_rate.sample(fuel / max_fuel) * _delta, max_fuel)

	speed_and_energy.secondary_charge = fuel / max_fuel

func texture_rect_tween(tex_rect: TextureRect) -> void:
	var tween := create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(tex_rect, "modulate", Color(255, 211, 0, 1) , 0.1)
	tween.parallel().tween_property(tex_rect, "scale", Vector2(1.2,1.2), 0.1)

func _on_timer_overcharged_timeout() -> void:
	speed_and_energy.animation_player.stop()
	overcharged.emit()
	set_process(false)
