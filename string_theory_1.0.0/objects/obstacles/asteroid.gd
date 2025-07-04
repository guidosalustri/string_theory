@tool
extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var point_light_2d: PointLight2D = $PointLight2D

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	modulate.a = 0
	monitorable=false
	animation_player.play("spin")
	scale= Vector2(0.6,0.6)

func activate(_time_to_activate: float) -> void:
	animation_player.play("activate")


func light_on(on) -> void:
	point_light_2d.enabled=on

func light_off() -> void:
	var tween:  Tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(point_light_2d, "texture_scale",0.0,0.5)
	#point_light_2d.hide()
	
