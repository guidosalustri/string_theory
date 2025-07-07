extends Node2D

@onready var sprite := $Sign
@onready var original_scale : Vector2
@export var level_idx = 0

func _ready() -> void:
	assert( sprite )
	original_scale = sprite.scale

func focus() -> void:
	var select := get_tree().create_tween()
	select.set_ease(Tween.EASE_IN)
	select.tween_property( sprite, "scale", original_scale * 1.4, 0.1 )
	select.tween_property( sprite, "self_modulate", Color.from_rgba8( 255, 213, 0 ), 0.14 )

func unfocus() -> void:
	var unselect_tween = get_tree().create_tween()
	unselect_tween.set_ease(Tween.EASE_OUT)
	unselect_tween.tween_property(
		sprite,
		"scale",
		original_scale,
		0.1 )
	unselect_tween.tween_property( sprite, "self_modulate", Color.WHITE, 0.14 )
