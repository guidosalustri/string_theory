@tool
extends Node2D

@export var obstacles : Array[Area2D]
	
@export_range(0, 2*PI, PI/16) var offset_angle: float = 0
@export_tool_button("Redo Obstacles") var redo_obstacles_tool_button = set_obstacles

@export var radius :float= 250
@export var anticlockwise := false
@export var rotation_speed: float = PI

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if obstacles.size() == 0:
		set_physics_process(false)
		return
	var fraction := 2*PI/obstacles.size()
	var vector_obstacle_pos := Vector2(radius,0.0)
	for i in range(obstacles.size()):
		obstacles[i].position = vector_obstacle_pos.rotated(i*fraction+offset_angle)
		if obstacles[i].is_in_group("blackhole"):
			obstacles[i].is_in_spinner = true
			obstacles[i].linear_speed_aprox = radius*(rotation_speed+1)
		if obstacles[i].is_in_group("asteroid"):
			obstacles[i].animation_player.play("spin")

func set_obstacles() -> void:
	if obstacles.size() == 0:
		set_physics_process(false)
		return
	var fraction := 2*PI/obstacles.size()
	var vector_obstacle_pos := Vector2(radius,0.0)
	for i in range(obstacles.size()):
		obstacles[i].position = vector_obstacle_pos.rotated(i*fraction+offset_angle)
		#if obstacles[i].is_in_group("blackhole"):
		#	obstacles[i].is_in_spinner = true
		#	obstacles[i].linear_speed_aprox = radius*(rotation_speed+1)
		#if obstacles[i].is_in_group("asteroid"):
		#	obstacles[i].animation_player.play("spin")

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if anticlockwise:
		rotation -= rotation_speed * delta
	else:
		rotation += rotation_speed * delta
