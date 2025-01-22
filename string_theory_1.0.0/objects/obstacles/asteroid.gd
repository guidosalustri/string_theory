extends Node2D


@onready var animation_player: AnimationPlayer = $Asteroid/AnimationPlayer
@onready var asteroid: Area2D = $Asteroid

@export var rotation_speed: float = PI
@export var asteroid_position: Vector2 = Vector2(300,0)
@export var anticlockwise := false

func _ready() -> void:
	asteroid.modulate.a = 0
	asteroid.monitorable=false
	animation_player.play("spin")
	asteroid.position = asteroid_position

func _process(delta):
	if anticlockwise:
		rotation -= rotation_speed * delta
	else:
		rotation += rotation_speed * delta

func activate(time_to_activate: float) -> void:
	animation_player.play("activate")
