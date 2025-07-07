extends Area2D

@onready var level_name: Label = $LevelName

@onready var button_glow: Sprite2D = $ButtonGlow
var original_scale: Vector2
var original_color: Color

signal pressed()

func _ready() -> void:
	original_scale = button_glow.scale
	original_color = button_glow.modulate
	connect("mouse_entered", func() -> void:
		var tween := get_tree().create_tween()
		tween.tween_property( button_glow, "scale", original_scale * 1.2, 0.1 )
		tween.tween_property( button_glow, "modulate", Color.from_rgba8(62, 218, 189), 0.1 )
	)
	connect("mouse_exited", func() -> void:
		var tween := get_tree().create_tween()
		tween.tween_property( button_glow, "scale", original_scale, 0.1 )
		tween.tween_property( button_glow, "modulate", original_color, 0.1 )
	)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			pressed.emit()

func set_level_name( name: String ) -> void:
	level_name.text = name
