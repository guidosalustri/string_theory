extends Node2D

@export var obstacles : Array[Area2D]

@export var radius :float= 250
@export var anticlockwise := false
@export var rotation_speed: float = PI

func _ready() -> void:
	if obstacles.size() == 0:
		set_process(false)
		return
	var fraction := 2*PI/obstacles.size()
	var vector_obstacle_pos := Vector2(radius,0.0)
	for i in range(obstacles.size()):
		obstacles[i].position = vector_obstacle_pos.rotated(i*fraction)
		if obstacles[i].is_in_group("blackhole"):
			obstacles[i].is_in_spinner = true
			obstacles[i].linear_speed_aprox = radius*(rotation_speed+1)
		if obstacles[i].is_in_group("asteroid"):
			obstacles[i].animation_player.play("spin")

func _process(delta):
	if anticlockwise:
		rotation -= rotation_speed * delta
	else:
		rotation += rotation_speed * delta
