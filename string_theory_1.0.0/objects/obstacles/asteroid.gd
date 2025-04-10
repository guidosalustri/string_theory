extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	modulate.a = 0
	monitorable=false
	animation_player.play("spin")
	scale= Vector2(0.6,0.6)

func activate(_time_to_activate: float) -> void:
	animation_player.play("activate")
