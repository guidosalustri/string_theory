extends Path2D

@export var move_speed := 0.2
@onready var path_follow_2d: PathFollow2D = $PathFollow2D
@onready var asteroid: Area2D = $PathFollow2D/Asteroid
@onready var trail_asteroid: GPUParticles2D = $PathFollow2D/Asteroid/TrailAsteroid
@onready var asteroid_trail: Line2D = $PathFollow2D/Asteroid/AsteroidTrail



var way_back := false

func _ready() -> void:
	asteroid.activate(1)
	await asteroid.animation_player.animation_finished
	asteroid.animation_player.play("spin")
	#trail_asteroid.emitting = true
	asteroid_trail.power = 1

func _process(delta: float) -> void:
	if way_back:
		path_follow_2d.progress_ratio -=move_speed*delta
	else:
		path_follow_2d.progress_ratio +=move_speed*delta
	
	if path_follow_2d.progress_ratio == 1:
		way_back=true
		asteroid_trail.hide()
		asteroid_trail.rotation = 0
		await get_tree().create_timer(0.1).timeout
		asteroid_trail.show()
	if path_follow_2d.progress_ratio == 0:
		way_back=false
		asteroid_trail.hide()
		asteroid_trail.rotation = PI
		await get_tree().create_timer(0.1).timeout
		asteroid_trail.show()
	
