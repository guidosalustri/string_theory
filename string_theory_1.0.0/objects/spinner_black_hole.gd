extends Node2D


@export var blackhole1 : Area2D
@export var blackhole2 : Area2D

@export var radius :float= 150
@export var anticlockwise := false
@export var rotation_speed: float = PI

func _ready() -> void:
	if blackhole1== null or blackhole2 == null:
		set_process(false)
		return
	#animation_player.play("spin")
	blackhole1.global_position = global_position + Vector2(radius,0)
	blackhole2.global_position = global_position - Vector2(radius,0)
	blackhole1.is_in_spinner = true
	blackhole2.is_in_spinner = true
	blackhole1.linear_speed_aprox = radius*(rotation_speed+1)
	blackhole2.linear_speed_aprox = radius*(rotation_speed+1)


func _process(delta):
	if anticlockwise:
		rotation -= rotation_speed * delta
	else:
		rotation += rotation_speed * delta
