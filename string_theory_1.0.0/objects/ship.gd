class_name Ship extends Area2D


@onready var _particles: GPUParticles2D = $Sprite2D/GPUParticles2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer

@export var max_speed := 700.0
@export var acceleration := 250.0
@export var turn_speed := 5.0

@export var turn_right := true
@export var turn_left := true
@export var move_forward := true
@export var invert_controls := false

enum States {
	ENTER_LVL,
	FLY,
	ORBIT,
	EXIT_LVL,
	DRAGGED
}

var current_state: States = States.ENTER_LVL:
	set = set_current_state

func set_current_state(new_state: States) -> void:
	current_state = new_state

var has_energy := true:
	set = set_has_energy

func set_has_energy(energy_update: bool) -> void:
	has_energy = energy_update
	
#signal change_vector(new_pos: Vector2)
signal change_star(star: Star)
signal cut_link

var speed := 450.0
# to check if the ship is on a star and in process should spin
# pos1 is the center of the circule where the ship spins
var flag := false
#var last_star := false
var pos1 := position
var target_offset := Vector2(50,0)
var target : Area2D
var black_hole : Area2D
var max_speed_hud := 700

#var start_offset := Vector2(50,0)

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	_particles.emitting = true
	max_speed_hud = max_speed


func _process(delta: float) -> void:
	# which movement the ship should have
	if ray_cast_2d.is_colliding():
		#print("holaa")
		target = ray_cast_2d.get_collider() #last_star:
	#if target:
	#	_follow(delta, target.global_position)
	#	flag = false
	##	target = ray_cast_2d.get_collider()
	#elif flag:
	#	_spin_around(delta, pos1)
	##elif ray_cast_2d.is_colliding():
	##	target = ray_cast_2d.get_collider() #last_star:
	##	_follow(delta, target.global_position)
	#else:
	#	_move(delta)
	
	match current_state:
		States.ENTER_LVL:
			#print("hola")
			#start_offset += Vector2(50,0)
			if timer.time_left > 0:
				speed += 1.0  * acceleration * delta
				speed = clamp(speed, 0.0, max_speed)
				var vel := (Vector2.RIGHT * speed).rotated(rotation)
				translate(vel * delta)
			else:
				if flag:
					set_current_state(States.ORBIT)
				elif black_hole:
					set_current_state(States.DRAGGED)
				#speed += -1.0  * acceleration * delta
			#speed = clamp(speed, 0.0, max_speed)
			#var velocity := (Vector2.RIGHT * speed).rotated(rotation)
			#translate(velocity * delta)
			
			#if (Input.is_action_pressed("move_up") and move_forward) or \
			#(Input.is_action_pressed("move_left") and turn_left) or \
			#(Input.is_action_pressed("move_right") and turn_right):
				else:
					set_current_state(States.FLY)
					set_has_energy(true)
			
			#elif flag:
			#	set_current_state(States.ORBIT)
			#elif black_hole:
			#	set_current_state(States.DRAGGED)
		States.FLY:
			_move(delta, turn_right, turn_left, move_forward)
			if flag:
				set_current_state(States.ORBIT)
			elif black_hole:
				set_current_state(States.DRAGGED)
		States.ORBIT:
			_spin_around(delta, pos1)
			set_has_energy(true)
			if target :
				cut_link.emit()
				set_current_state(States.EXIT_LVL)
			elif black_hole:
				set_current_state(States.DRAGGED)
			elif Input.is_action_pressed("spin"):
				set_current_state(States.FLY)
		States.DRAGGED:
			_follow(delta, black_hole.global_position)
		States.EXIT_LVL:
			target_offset+= Vector2(50,0)
			_follow(delta, target.global_position + target_offset)

	if speed<=0:
		_particles.emitting = false
		if not has_energy:
			cut_link.emit()
			animation_player.play("die")
			#should run GameManager.ship_dead() but wan time
			#I need ot put it in the animaiton itself.

# steering 
func _move(delta: float, right: bool , left: bool, forward: bool) -> void:
	#this is for testing but the idea is to make the ship lose speed when is not spinning
	speed += (1.0 if Input.is_action_pressed("move_up") and \
	forward and has_energy else -1.0) * acceleration * delta #and has_energy
	speed = clamp(speed, 0.0, max_speed)
	
	if invert_controls:
		if Input.is_action_pressed("move_left") and right:
			rotate(turn_speed * delta)
		if Input.is_action_pressed("move_right") and left:
			rotate(-turn_speed * delta)
	else:
		if Input.is_action_pressed("move_left") and left:
			rotate(-turn_speed * delta)
		if Input.is_action_pressed("move_right") and right:
			rotate(turn_speed * delta)

	var velocity := (Vector2.RIGHT * speed).rotated(rotation)
	translate(velocity * delta)

# circular movment
func _spin_around(delta: float, pos: Vector2) -> void:
	speed += 1.0 * acceleration * delta
	speed = clamp(speed, 0.0, max_speed)

	# dir is vector that points from the ship to the star
	var dir := (pos - position).normalized()
	var velocity := dir * speed
	# v is a vector that tell us where the ship is looking at (when it enters the star area)
	var v := Vector2(1,0).rotated(rotation)
	# depending on the angle between v and dir the ship should spin in one or
	# other direction
	if dir.angle_to(v) >= 0: 
		velocity= velocity.rotated(PI/2)
	else:
		velocity= velocity.rotated(-PI/2)
	# corrects a bit the angle
	rotate(v.angle_to(velocity))
	translate(velocity * delta)

func _follow(delta: float, target: Vector2) -> void:
	#var velocity
	if position.distance_to(target) > 10:
		var direction := global_position.direction_to(target)
		var velocity := direction * speed
	#var desired_velocity := speed * direction
	#var steering_vector := desired_velocity - velocity 
	#velocity += steering_vector * drag_factor
	#position += velocity * delta
		translate(velocity * delta)
		if not black_hole:
			rotation = velocity.angle()
	#if (position - target).x <= 1:
	#	hide()
	elif black_hole:
		animation_player.play("die")

# key to fly to next star
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_up") or event.is_action_pressed("spin"):
		_particles.emitting = true
	if event.is_action_pressed("spin"):
		flag= false

# ship landed on a star area
func _on_area_entered(area: Area2D)->void:
	if area is Star:
		var star : Star = area as Star
		match star.current_state:
			star.States.STAR:
				change_star.emit(star)
				flag=true
				pos1 = area.global_position
			star.States.BLACK_HOLE:
				black_hole = area
				if speed < 500:
					speed = 500
				cut_link.emit()
				GameManager.ship_dead()
	if area.is_in_group("blackhole"):
		#var blackhole : BlackHole = area as BlackHole
		black_hole = area
		if speed < 500:
			speed = 500
		if black_hole.is_in_spinner:
			max_speed = black_hole.linear_speed_aprox
			speed = black_hole.linear_speed_aprox
		#reparent(blackhole)
		#print(speed)
		cut_link.emit()
		GameManager.ship_dead()
	if area.is_in_group("asteroid"):
		explote()

func restart_lvl() -> void:
	GameManager.next_lvl(GameManager.lvl)

func explote() -> void:
	animation_player.play("asteroid_die")
	cut_link.emit()
	GameManager.ship_dead()
