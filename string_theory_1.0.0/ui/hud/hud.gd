extends Control

@onready var grid_container: GridContainer = $GridContainer
@onready var texture_rect: TextureRect = $GridContainer/TextureRect
@onready var label_speed: Label = $Speedometer/Label
@onready var panel_speed: Panel = $Speedometer/PanelFront
@onready var panel_fuel:= $FuelBar/PanelFront
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer_overcharged: Timer = $TimerOvercharged

@export var fuel_fill_rate : Curve
@export var fuel_burn_rate : Curve
@export var max_fuel:= 5.0
var fuel := 2.5

signal overcharged
signal no_energy

var index : = 0

var player: Ship

var stars_trail: Array[Star]:
	set = set_stars_trail

func set_stars_trail(stars: Array[Star]) -> void:
	stars_trail = stars
	for i in range(stars_trail.size()):
		if i>0:
			grid_container.add_child(texture_rect.duplicate())
		if not stars_trail[i].star_entered.is_connected(_on_star_entered_star_ui):
			# only connect unique stars
			stars_trail[i].star_entered.connect(_on_star_entered_star_ui)


func _ready() -> void:
	timer_overcharged.timeout.connect(_on_timer_overcharged_timeout)

func _process(_delta: float) -> void:
	var ship_speed : int = clamp(player.speed, 0, player.max_speed_hud)
	label_speed.text = str(snapped(ship_speed,20))
	panel_speed.material.set_shader_parameter("value", (ship_speed * 0.75)/ player.max_speed_hud)

	if player and player.current_state == Ship.States.FLY:
		fuel = max ( fuel -  2.0 * fuel_burn_rate.sample( 1.0 - fuel / max_fuel ) * _delta, 0 )

	if fuel <= 0:
		no_energy.emit()
	
	if fuel >= max_fuel and timer_overcharged.is_stopped():
		timer_overcharged.start()
		animation_player.play("full_energy")

	if fuel < max_fuel and not timer_overcharged.is_stopped():
		timer_overcharged.stop()
		animation_player.stop()

	if player.current_state == player.States.ORBIT:
		fuel = min(fuel + fuel_fill_rate.sample(fuel / max_fuel) * _delta, max_fuel)

	panel_fuel.material.set_shader_parameter("value", fuel / max_fuel)

func _on_star_entered_star_ui() -> void:
	if stars_trail[index].is_state_star():
		if index == stars_trail.size()-1:
			texture_rect_tween(grid_container.get_child(index))
			return

		texture_rect_tween(grid_container.get_child(index))
		index += 1

func texture_rect_tween(tex_rect: TextureRect) -> void:
	var tween := create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(tex_rect, "modulate", Color(255, 211, 0, 1) , 0.1)
	tween.parallel().tween_property(tex_rect, "scale", Vector2(1.2,1.2), 0.1)

func _on_timer_overcharged_timeout() -> void:
	animation_player.stop()
	overcharged.emit()
	set_process(false)
