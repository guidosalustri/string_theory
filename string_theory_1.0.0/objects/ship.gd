class_name Ship extends Area2D

@onready var side_thruster_left: Sprite2D = $Sprite2D/SideThrusterLeft
@onready var side_thruster_right: Sprite2D = $Sprite2D/SideThrusterRight
@onready var main_thruster: Line2D = $Sprite2D/MainThruster

@onready var sprite_2d: Sprite2D = $Sprite2D
var _physics_body_trans_last: Transform2D
var _physics_body_trans_current: Transform2D

@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer
@onready var point_light_2d: PointLight2D = $PointLight2D
@onready var dash_timer: Timer = $DashTimer
@onready var dash_gpu_particles: GPUParticles2D = $Sprite2D/GPUParticles2D
@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

#const THRUSTER_FIRE_002 = preload("res://assets/audio/ship_sfx/thruster_fire_002.ogg")
#const SPACE_ENGINE_003 = preload("res://assets/audio/ship_sfx/space_engine_003.ogg")

@export var max_speed := 700.0
@export var acceleration := 250.0
@export var turn_speed := 5.0

@export var max_fuel:= 5.0
@export var fuel_fill_rate := 2.0
@export var fuel_burn_rate := 1.0
@export var fuel := 2.5

func set_fuel(new_fuel: float) -> void:
	fuel = new_fuel

var fuel_left := max_fuel / 2.0
var fuel_right := max_fuel / 2.0

@export var turn_right := true
@export var turn_left := true
@export var move_forward := true
@export var invert_controls := false
@export var lvl_with_dash := false

var has_fuel: bool:
	get: return fuel > 0
var has_fuel_left: bool:
	get: return fuel_left > 0
var has_fuel_right: bool:
	get: return fuel_right > 0

var target_star : Node2D

enum States {
	#ENTER_LVL,
	FLY,
	ORBIT,
	EXIT_LVL,
	DRAGGED
}

var current_state: States = States.FLY:
	set = set_current_state

func set_current_state(new_state: States) -> void:
	if current_state == States.FLY and new_state == States.ORBIT:
		#audio_stream_player_2d.stream =SPACE_ENGINE_003
		#audio_stream_player_2d.play()
		GameManager.data_collection.log_attach_detach_to_star( DataCollection.ship_action.ATTACH, fuel / max_fuel )
	elif current_state == States.ORBIT and new_state == States.FLY:
		var v0 := Vector2( cos(rotation), sin(rotation) )
		var v1 := Vector2( target_star.global_position ) - global_position
		v1 = v1.normalized()
		GameManager.data_collection.log_attach_detach_to_star( DataCollection.ship_action.DETACH, fuel / max_fuel )
		GameManager.data_collection.log_aim_score( v0.dot(v1) )
	current_state = new_state


var has_energy := true:
	set = set_has_energy

func set_has_energy(energy_update: bool) -> void:
	has_energy = energy_update

signal star_entered(star: Star)
signal cut_link(was_black_hole: bool)
signal dash

var speed := 450.0
var dashing := false
var can_dash := false

# to check if the ship is on a star and in process should spin
var flag := false
# pos1 is the center of the circule where the ship spins
var pos1 := position
var target_offset := Vector2(50,0)
var target : Area2D
var black_hole : Area2D
var max_speed_hud := 700
var lvls_with_not_foward : bool= (GameManager.lvl == 7 or \
	GameManager.lvl == 8 or GameManager.lvl == 9 or GameManager.lvl == 11) 
var is_last_star := false

var dying := false

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	dash_timer.timeout.connect(_on_dash_timer_timeout)
	max_speed_hud = int(max_speed)
	can_dash = lvl_with_dash

func _physics_process(delta: float) -> void:
	# Decrease energy level
	if current_state == Ship.States.FLY:
		fuel = max ( fuel -  fuel_burn_rate * delta, 0 )
		if Input.is_action_pressed("move_left"):
			fuel_left = max ( fuel_left -  fuel_burn_rate * delta, 0 )
		if Input.is_action_pressed("move_right"):
			fuel_right = max ( fuel_right -  fuel_burn_rate * delta, 0 )

	# Increase energy level
	if current_state == States.ORBIT:
		fuel = min(fuel + fuel_fill_rate * delta, max_fuel)
		fuel_left = min(fuel_left + fuel_fill_rate / 2.0 * delta, max_fuel)
		fuel_right = min(fuel_right + fuel_fill_rate / 2.0 * delta, max_fuel)
	
	GameManager.data_collection.log_player_pos(position, rotation)
	
	# which movement the ship should have
	if ray_cast_2d.is_colliding():

		target = ray_cast_2d.get_collider() #last_star:

	match current_state:
		States.FLY:
			side_thruster_left.emit = true
			side_thruster_right.emit = true
			_move(delta, turn_right, turn_left, move_forward)
			if flag:
				set_current_state(States.ORBIT)
				side_thruster_left.emit = false
				side_thruster_right.emit = false
			elif black_hole:
				set_current_state(States.DRAGGED)
				side_thruster_left.emit = false
				side_thruster_right.emit = false
		States.ORBIT:
			_spin_around(delta, pos1)
			set_has_energy(true)
			if target :
				#cut_link.emit(false)
				set_current_state(States.EXIT_LVL)
			elif black_hole:
				set_current_state(States.DRAGGED)
			elif Input.is_action_pressed("spin") and not is_last_star:
				set_current_state(States.FLY)
		States.DRAGGED:
			_follow(delta, black_hole.global_position)
		States.EXIT_LVL:
			target_offset+= Vector2(50,0)
			_follow(delta, target.global_position + target_offset)
			#main_thruster.power = 1.0
	if current_state != States.ORBIT and  current_state != States.DRAGGED and has_energy:
		main_thruster.thruster_on = true
	else:
		main_thruster.thruster_on = false
	if speed<=0:
		if (not has_energy or lvls_with_not_foward) and not dying:
			dying = true
			GameManager.data_collection.log_player_death(DataCollection.player_death_cause.OUT_OF_FUEL)
			cut_link.emit(false)
			animation_player.play("die")
	else:
		dying = false

	_physics_body_trans_last = _physics_body_trans_current
	_physics_body_trans_current = global_transform

func _process(delta: float) -> void:
	sprite_2d.global_transform = get_smooth_transform()

# steering 
func _move(delta: float, right: bool, left: bool, forward: bool) -> void:

	#speed += (1.0 if Input.is_action_pressed("move_up") and \
	#forward and has_energy else -1.0) * acceleration * delta
	speed += (1.0 if forward and has_energy \
	else -1.0) * acceleration * delta
	speed = clamp(speed, 0.0, max_speed)
	
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if not left or not has_fuel_left:
		direction.x = maxf(0.0, direction.x)
	if not right or not has_fuel_right:
		direction.x = minf(0.0, direction.x)
	if invert_controls:
		direction.x *= -1
	var turn_speed_dt : float = sign(direction.x) * turn_speed * delta
	
	if dashing:
		speed = 2800.0
	else: 
		rotate(turn_speed_dt)


	if sign(turn_speed_dt) == 1:
		side_thruster_right.power = 0
	elif sign(turn_speed_dt) == -1:
		side_thruster_left.power = 0
	else:
		side_thruster_left.power = 0
		side_thruster_right.power = 0

	var velocity := (Vector2.RIGHT * speed).rotated(rotation)
	translate(velocity * delta)

const ship_orbiting_factor = PI/2 - PI/64

# circular movment
func _spin_around(delta: float, pos: Vector2) -> void:
	speed += 1.0 * acceleration * delta
	speed = clamp(speed, 0.0, max_speed)

	# dir is vector that points from the ship to the star
	var dir := (pos - position).normalized()
	var velocity := dir * speed
	# v is a vector that tell us where the ship is looking at (when it enters the star area)
	var v := Vector2(1, 0).rotated(rotation)
	# depending on the angle between v and dir the ship should spin in one or
	# other direction
	if dir.angle_to(v) >= 0:
		velocity = velocity.rotated( ship_orbiting_factor )
	else:
		velocity = velocity.rotated( -ship_orbiting_factor )
	# corrects a bit the angle
	rotate(v.angle_to(velocity))
	translate(velocity * delta)

func _follow(delta: float, pos: Vector2) -> void:
	if position.distance_to(pos) > 10:
		var direction := global_position.direction_to(pos)
		var velocity := direction * speed

		translate(velocity * delta)
		if not black_hole:
			rotation = velocity.angle()

	elif black_hole:
		animation_player.play("die")

# key to fly to next star
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("spin"):
		if current_state == States.ORBIT:
			flag= false
		if current_state == States.FLY and not dashing and lvl_with_dash:
			if can_dash:# and has_energy:
				dash.emit()
				dashing = true
				set_collision_mask_value(3,false)
				set_collision_mask_value(4,false)
				dash_timer.start()
				dash_gpu_particles.process_material.angle_min = -rotation_degrees
				dash_gpu_particles.process_material.angle_max = -rotation_degrees
				dash_gpu_particles.emitting=true
			else:
				dash.emit()

# ship landed on a star area
func _on_area_entered(area: Area2D)->void:
	if black_hole ==null:
		if area is Star:
			var star : Star = area as Star
			match star.current_state:
				star.States.STAR:
					star_entered.emit(star)
					flag=true
					pos1 = area.global_position
				star.States.BLACK_HOLE:
					black_hole = area
					if speed < 500:
						speed = 500
					cut_link.emit(true)
					GameManager.data_collection.log_player_death(DataCollection.player_death_cause.BLACK_HOLE)
		if area.is_in_group("blackhole"):
			black_hole = area
			if speed < 500:
				speed = 500
			if black_hole.is_in_spinner:
				max_speed = black_hole.linear_speed_aprox
				speed = black_hole.linear_speed_aprox
			cut_link.emit(true)
			GameManager.data_collection.log_player_death(DataCollection.player_death_cause.BLACK_HOLE)
		if area.is_in_group("asteroid"):
			GameManager.data_collection.log_player_death(DataCollection.player_death_cause.ASTEROID)
			explode()

func restart_lvl() -> void:
	GameManager.start_lvl(GameManager.lvl)

func explode() -> void:
	animation_player.play("asteroid_die")
	set_process(false)
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	cut_link.emit(false)
	audio_stream_player_2d.play()

func dim_light_on(turn_light_on: bool) -> void:
	#this should be carfully balance
	if turn_light_on:
		point_light_2d.texture_scale += 0.015	
		point_light_2d.energy += 0.0008
	else:
		point_light_2d.texture_scale -= 0.015
		point_light_2d.energy -= 0.0005
	var energy := clampf(point_light_2d.energy,0.1,0.4)
	var value := clampf(point_light_2d.texture_scale,3,19)
	point_light_2d.texture_scale = value
	point_light_2d.energy = energy
	#if value <= 2:
		#cut_link.emit(false)
		#set_process(false)
		#animation_player.play("die")

func _on_dash_timer_timeout() -> void:
	set_collision_mask_value(3,true)
	set_collision_mask_value(4,true)
	dash_gpu_particles.emitting=false
	dashing = false

func get_smooth_transform() -> Transform2D:
	return \
		_physics_body_trans_last.interpolate_with(
			_physics_body_trans_current,
			Engine.get_physics_interpolation_fraction()
		)
