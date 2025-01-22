extends Control


#@onready var _progress_bar: ProgressBar = %ProgressBar
@onready var grid_container: GridContainer = $GridContainer
@onready var texture_rect: TextureRect = $GridContainer/TextureRect
@onready var label_speed: Label = $Speedometer/Label
@onready var panel_speed: Panel = $Speedometer/PanelFront
@onready var panel_fuel: Panel = $FuelBar/PanelFront
@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer_overcharged: Timer = $TimerOvercharged

@export var time_max_fuel: float =5

signal overcharged
signal no_energy
#var distance_between_stars := 0
var index : = 0
#var next_star_pos : Vector2 = Vector2(0,0)
#var max_speed := 0

var player: Ship:
	set = set_player

var stars_trail: Array[Star]:
	set = set_stars_trail

func set_player(ship: Ship) -> void:
	player = ship
	#max_speed= player.max_speed

func set_stars_trail(stars: Array[Star]) -> void:
	stars_trail = stars
	for i in range(stars_trail.size()):
		if i>0:
			grid_container.add_child(texture_rect.duplicate())
		stars_trail[i].star_entered.connect(_on_star_entered_star_ui)
		#print(i)
	#stars_trail[-1].star_entered.connect(func()->void:
	#	texture_rect_tween(h_box_container.get_child(-1))
	#	)

func _ready() -> void:
	timer.wait_time = time_max_fuel
	timer_overcharged.timeout.connect(_on_timer_overcharged_timeout)

func _process(_delta: float) -> void:
	var ship_speed = clamp(int(player.speed), 0.0, player.max_speed_hud)
	label_speed.text = str(snapped(ship_speed,20))
	panel_speed.material.set_shader_parameter("value", (ship_speed * 0.75)/ player.max_speed_hud)
	
	
	#if player.current_state == player.States.ORBIT: #and index > 0:
		#why 100? no idea (ojo se completa antes aveces)
		#_progress_bar.set_as_ratio(
			#inverse_lerp(distance_between_stars - 100, \
			#0 + 100, player.position.distance_to(next_star_pos))
		#)
	if panel_fuel.material.get_shader_parameter("value") == 0:
		no_energy.emit()
		# once singal is used add in this line return
	
	if panel_fuel.material.get_shader_parameter("value") == 1 and timer_overcharged.is_stopped():
		timer_overcharged.start()
		animation_player.play("full_energy")
	
	if panel_fuel.material.get_shader_parameter("value") < 1 and not timer_overcharged.is_stopped():
		timer_overcharged.stop()
		animation_player.stop()
	
	if player.current_state == player.States.ORBIT:
		var plus_time = clamp(timer.time_left + (_delta*2), 0, time_max_fuel)
		timer.start(plus_time)
	#print(timer.time_left)
	
	panel_fuel.material.set_shader_parameter("value", timer.time_left/ time_max_fuel)

func _on_star_entered_star_ui() -> void:
	if index == stars_trail.size()-1:
		texture_rect_tween(grid_container.get_child(index))
		return
	#distance_between_stars = stars_trail[index].position.distance_to( stars_trail[index+1].position)
	#next_star_pos = stars_trail[index+1].position
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
