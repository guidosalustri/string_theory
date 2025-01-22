extends Sprite2D

signal animation_finished

@export var pulse_duration := 2.0
@export var pulse_final_scale := Vector2(1.5, 1.5)

var _current_tween: Tween = null


func _ready() -> void:
	animation_finished.connect(_pulse)
	_pulse()


func _pulse() -> void:
	if _current_tween != null and _current_tween.is_running():
		_current_tween.stop()

	_current_tween = create_tween()
	_current_tween.tween_property(self, "scale", pulse_final_scale, pulse_duration)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_OUT)
	_current_tween.tween_property(self, "scale", Vector2.ONE, pulse_duration)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN_OUT)
	_current_tween.tween_callback(func() -> void: 
		animation_finished.emit()
	)
