extends Line2D

@onready var curve : Curve2D = Curve2D.new()
@onready var collision_gpu_particles_2d: GPUParticles2D = $CollisionGPUParticles2D

var line_created := false
var target : Ship= null
var was_black_hole := false

func _physics_process(_delta: float) -> void:
	if points.size() > 21:
		for i in range(20):
			remove_point(0)
			collision_gpu_particles_2d.position = points[0]
	elif points.size() > 1:
		remove_point(0)
		collision_gpu_particles_2d.position = points[0]
	if line_created:
		if target:
			add_point(target.global_position)
		if points.size() == 1:
			queue_free()

func create_line(v1: Vector2,v2: Vector2) -> void:
	var dir := v1.direction_to(v2)
	var d := v1.distance_to(v2)
	var d_between_points := d/2
	var random_v := generate_random_vector(d_between_points)
	for i in range(2):
		random_v = generate_random_vector(d_between_points/2)
		if i==0:
			curve.add_point(v1+(dir*d_between_points*i),Vector2.ZERO,random_v)
		else:
			curve.add_point(v1+(dir*d_between_points*i),random_v,-random_v)
	curve.add_point(v2,generate_random_vector(d_between_points/2),Vector2.ZERO)
	line_created = true
	points = curve.get_baked_points()
	collision_gpu_particles_2d.position = points[0]
	collision_gpu_particles_2d.emitting = true

static func generate_random_vector(maximum_length: float) -> Vector2:
	var random_direction := Vector2.from_angle(randf_range(PI/2,PI))
	var random_length := randf_range(30, maximum_length)
	return random_direction * random_length
